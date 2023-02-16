//
//  AddView.swift
//  iExpense
//
//  Created by Ангелина Шаманова on 7.2.23..
//

import SwiftUI

enum ExpenseType: String, Codable {
    case personal = "Personal"
    case business = "Business"
}

struct AddView: View {
    @ObservedObject var expenses: Expenses
    
    @State private var name = ""
    @State private var type: ExpenseType = .personal
    @State private var amount = 0.0
    @State private var currencyType: CurrencyType = .dollar
    
    @Environment(\.dismiss) private var dismiss
    
    private let types: [ExpenseType] = [.personal, .business]
    private let currencyTypes: [CurrencyType] = [.dollar, .euro, .ruble]
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                Picker("Type", selection: $type) {
                    ForEach(types, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                HStack {
                    Picker("Currency type", selection: $currencyType) {
                        ForEach(currencyTypes, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                }
                TextField("Amount", value: $amount, format: .number)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Add new expense")
            .toolbar {
                Button("Save") {
                    let item = ExpenseItem(name: name,
                                           type: type,
                                           currencyType: currencyType,
                                           amount: amount)
                    if type == .personal {
                        expenses.personalExpenses.append(item)
                    } else {
                        expenses.businessExpenses.append(item)
                    }
                    dismiss()
                }
            }
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(expenses: Expenses())
    }
}
