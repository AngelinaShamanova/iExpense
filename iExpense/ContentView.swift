//
//  ContentView.swift
//  iExpense
//
//  Created by Ангелина Шаманова on 10.1.23..
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let type: ExpenseType
    let currencyType: CurrencyType
    let amount: Double
    
    var color: Color {
        switch currencyType {
        case .dollar, .euro:
            return amount <= 100 ? .gray.opacity(0.7) : .pink.opacity(0.7)
        case .ruble:
            return amount <= 2000 ? .gray.opacity(0.7) : .pink.opacity(0.7)
        }
    }
}

enum CurrencyType: String, Codable {
    case dollar = "USD"
    case euro = "EUR"
    case ruble = "RUB"
}

class Expenses: ObservableObject {
    @Published var personalExpenses = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(personalExpenses) {
                UserDefaults.standard.set(encoded, forKey: "personalExpenses")
            }
        }
    }
    
    @Published var businessExpenses = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(businessExpenses) {
                UserDefaults.standard.set(encoded, forKey: "businessExpenses")
            }
        }
    }
    
    init() {
        if let savedPersonalItems = UserDefaults.standard.data(forKey: "personalExpenses") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedPersonalItems) {
                personalExpenses = decodedItems
            }
        } else {
            personalExpenses = []
        }
        if let savedBusinessItems = UserDefaults.standard.data(forKey: "businessExpenses") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedBusinessItems) {
                businessExpenses = decodedItems
            }
        } else {
            businessExpenses = []
        }
    }
}

struct ContentView: View {
    @StateObject var expenses = Expenses()
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationView {
            List {
                Section(ExpenseType.personal.rawValue) {
                    ForEach(expenses.personalExpenses) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.type.rawValue)
                            }
                            Spacer()
                            Text(item.amount, format: .currency(code: item.currencyType.rawValue))
                            
                        }
                        .listRowBackground(item.color)
                    }
                    .onDelete(perform: removePersonalItems)
                }
                Section(ExpenseType.business.rawValue) {
                    ForEach(expenses.businessExpenses) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.type.rawValue)
                            }
                            Spacer()
                            Text(item.amount, format: .currency(code: item.currencyType.rawValue))
                            
                        }
                        .listRowBackground(item.color)
                    }
                    .onDelete(perform: removeBusinessItems)
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: expenses)
            }
            .navigationTitle("iExpense")
            .toolbar {
                EditButton()
                Button {
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private func removePersonalItems(at offsets: IndexSet) {
        expenses.personalExpenses.remove(atOffsets: offsets)
    }
    
    private func removeBusinessItems(at offsets: IndexSet) {
        expenses.businessExpenses.remove(atOffsets: offsets)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
