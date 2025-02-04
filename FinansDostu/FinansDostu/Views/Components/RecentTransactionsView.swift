import SwiftUI

struct RecentTransactionsView: View {
    let transactions: [Transaction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if transactions.isEmpty {
                Text("İşlem bulunmuyor")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(transactions.prefix(5)) { transaction in
                    TransactionRow(transaction: transaction)
                    
                    if transaction.id != transactions.prefix(5).last?.id {
                        Divider()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.subheadline)
                Text(transaction.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(String(format: "%.2f ₺", transaction.amount))
                .foregroundStyle(transaction.type == .expense ? .red : .green)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
} 