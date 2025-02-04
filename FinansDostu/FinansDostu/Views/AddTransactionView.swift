import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: MainViewModel
    
    @State private var title = ""
    @State private var amount = ""
    @State private var type: Transaction.TransactionType = .expense
    @State private var category = "Diğer"
    @State private var note = ""
    @State private var date = Date()
    @State private var showingCategories = false
    
    private let categories = [
        "Market", "Faturalar", "Ulaşım", "Sağlık", 
        "Eğlence", "Alışveriş", "Maaş", "Ek Gelir", "Diğer"
    ]
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground)
    }
    
    private var typeColor: Color {
        type == .income ? 
            (colorScheme == .dark ? Color.green.opacity(0.3) : Color.green.opacity(0.15)) :
            (colorScheme == .dark ? Color.red.opacity(0.3) : Color.red.opacity(0.15))
    }
    
    private var amountColor: Color {
        type == .income ? .green : .red
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Gelir/Gider Seçici
                        HStack(spacing: 12) {
                            // Gider Butonu
                            Button {
                                withAnimation { type = .expense }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.down.circle.fill")
                                    Text("Gider")
                                }
                                .font(.headline)
                                .foregroundStyle(type == .expense ? .red : .gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(type == .expense ? Color.red.opacity(0.15) : Color(.systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            // Gelir Butonu
                            Button {
                                withAnimation { type = .income }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.up.circle.fill")
                                    Text("Gelir")
                                }
                                .font(.headline)
                                .foregroundStyle(type == .income ? .green : .gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(type == .income ? Color.green.opacity(0.15) : Color(.systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.top)
                        
                        // Tutar Girişi
                        VStack(spacing: 8) {
                            Text(amount.isEmpty ? "0.00 ₺" : "\(amount) ₺")
                                .font(.system(size: 44, weight: .medium, design: .rounded))
                                .foregroundStyle(amountColor)
                                .frame(height: 60)
                            
                            // Numerik Klavye
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                                ForEach(1...9, id: \.self) { number in
                                    NumberButton(number: "\(number)", action: { appendNumber("\(number)") })
                                }
                                NumberButton(number: ".", action: { appendNumber(".") })
                                NumberButton(number: "0", action: { appendNumber("0") })
                                NumberButton(number: "⌫", action: deleteLastNumber)
                            }
                        }
                        .padding()
                        .background(cardBackgroundColor)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.05), radius: 10)
                        
                        // İşlem Detayları
                        VStack(spacing: 16) {
                            // Başlık
                            InputField(
                                icon: "text.alignleft",
                                placeholder: "Başlık",
                                text: $title
                            )
                            
                            // Kategori
                            Button {
                                showingCategories = true
                            } label: {
                                HStack {
                                    Image(systemName: "tag.fill")
                                        .font(.title2)
                                        .foregroundStyle(.blue)
                                    Text(category)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.gray)
                                }
                                .padding()
                                .background(cardBackgroundColor)
                                .cornerRadius(12)
                            }
                            
                            // Tarih
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                                DatePicker("", selection: $date, displayedComponents: [.date])
                                    .labelsHidden()
                            }
                            .padding()
                            .background(cardBackgroundColor)
                            .cornerRadius(12)
                            
                            // Not
                            InputField(
                                icon: "note.text",
                                placeholder: "Not (İsteğe bağlı)",
                                text: $note
                            )
                        }
                        
                        // Kaydet Butonu
                        Button(action: saveTransaction) {
                            Text("Kaydet")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    canSave ?
                                    LinearGradient(
                                        colors: type == .income ? [.green, .green.opacity(0.8)] : [.red, .red.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        colors: [.gray, .gray.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .disabled(!canSave)
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle("Yeni İşlem")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCategories) {
                CategoryPickerView(selectedCategory: $category)
            }
        }
    }
    
    private var canSave: Bool {
        !title.isEmpty && !amount.isEmpty && Double(amount) != nil
    }
    
    private func appendNumber(_ number: String) {
        if number == "." && amount.contains(".") { return }
        if amount.contains(".") {
            let decimalPlaces = amount.split(separator: ".")[1].count
            if decimalPlaces >= 2 { return }
        }
        amount += number
    }
    
    private func deleteLastNumber() {
        if !amount.isEmpty {
            amount.removeLast()
        }
    }
    
    private func saveTransaction() {
        if let amountDouble = Double(amount), !title.isEmpty {
            viewModel.addTransaction(
                title: title,
                amount: amountDouble,
                type: type,
                category: category,
                date: date,
                note: note.isEmpty ? nil : note
            )
            dismiss()
        }
    }
}

struct InputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.sentences)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct NumberButton: View {
    let number: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(number)
                .font(.title2.weight(.medium))
                .foregroundStyle(.primary)
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
}

struct CategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategory: String
    
    let categories = [
        "Market", "Faturalar", "Ulaşım", "Sağlık", 
        "Eğlence", "Alışveriş", "Maaş", "Ek Gelir", "Diğer"
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        dismiss()
                    }) {
                        HStack {
                            Text(category)
                                .foregroundStyle(.primary)
                            Spacer()
                            if category == selectedCategory {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Kategori Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
} 
