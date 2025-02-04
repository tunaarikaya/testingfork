import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showingAddTransaction = false
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var expandedSection: ExpandedSection? = nil
    
    enum ExpandedSection {
        case recentTransactions
        case plannedPayments
        case budgetAssistant
    }
    
    var filteredTransactions: [Transaction] {
        if searchText.isEmpty {
            return viewModel.transactions
        } else {
            return viewModel.transactions.filter { transaction in
                transaction.title.localizedCaseInsensitiveContains(searchText) ||
                transaction.category.localizedCaseInsensitiveContains(searchText) ||
                String(format: "%.2f", transaction.amount).contains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Karşılama Başlığı
            HStack(spacing: 12) {
                // Profil Fotosu
                if let profileImage = viewModel.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        .background(
                            Circle()
                                .fill(.white)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.blue)
                        .background(
                            Circle()
                                .fill(.white)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.user.name)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("Hoş Geldiniz")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 16)
            
            // Bakiye Kartı
            BalanceCard(balance: viewModel.user.balance)
                .padding(.horizontal)
                .padding(.bottom, 8)
            
            // Arama Çubuğu
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    
                    TextField("İşlem Ara...", text: $searchText)
                        .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 16) {
                    if !searchText.isEmpty {
                        // Arama Sonuçları
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Arama Sonuçları")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if filteredTransactions.isEmpty {
                                Text("Sonuç bulunamadı")
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else {
                                ForEach(filteredTransactions) { transaction in
                                    SearchTransactionRow(transaction: transaction)
                                    
                                    if transaction.id != filteredTransactions.last?.id {
                                        Divider()
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    } else {
                        // Normal İçerik - Açılır Kapanır Kutular
                        VStack(spacing: 16) {
                            // Son İşlemler Kutusu
                            ExpandableSection(
                                title: "Son İşlemler",
                                icon: "clock.fill",
                                iconColor: .blue,
                                isExpanded: expandedSection == .recentTransactions
                            ) {
                                expandedSection = expandedSection == .recentTransactions ? nil : .recentTransactions
                            } content: {
                                RecentTransactionsView(transactions: viewModel.transactions)
                            }
                            
                            // Planlı Ödemeler Kutusu
                            ExpandableSection(
                                title: "Planlı Ödemeler",
                                icon: "calendar.badge.clock",
                                iconColor: .orange,
                                isExpanded: expandedSection == .plannedPayments
                            ) {
                                expandedSection = expandedSection == .plannedPayments ? nil : .plannedPayments
                            } content: {
                                PlannedPaymentsView(payments: viewModel.plannedPayments)
                            }
                            
                            // Bütçe Asistanı Kutusu
                            ExpandableSection(
                                title: "Bütçe Asistanı",
                                icon: "chart.pie.fill",
                                iconColor: .purple,
                                isExpanded: expandedSection == .budgetAssistant
                            ) {
                                expandedSection = expandedSection == .budgetAssistant ? nil : .budgetAssistant
                            } content: {
                                BudgetSummaryView(insights: viewModel.categoryInsights)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddTransaction = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.tint)
                }
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView(viewModel: viewModel)
        }
        .onReceive(NotificationCenter.default.publisher(for: .userProfileUpdated)) { _ in
            viewModel.objectWillChange.send()
        }
    }
}

struct ExpandableSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let isExpanded: Bool
    let onTap: () -> Void
    let content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            // Başlık Butonu
            Button(action: onTap) {
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(iconColor)
                    
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.gray)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            
            // İçerik
            if isExpanded {
                content()
                    .padding(.top, 8)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .animation(.spring(), value: isExpanded)
    }
}

struct SearchTransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.system(.body, design: .rounded))
                
                Text(transaction.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(String(format: "%.2f ₺", transaction.amount))
                .font(.system(.callout, design: .rounded, weight: .medium))
                .foregroundStyle(transaction.type == .income ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}
