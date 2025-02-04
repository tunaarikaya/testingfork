import SwiftUI

struct PlannedPaymentsView: View {
    let payments: [PlannedPayment]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if payments.isEmpty {
                Text("Planlı ödeme bulunmuyor")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(payments) { payment in
                    PlannedPaymentRow(payment: payment)
                    
                    if payment.id != payments.last?.id {
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

