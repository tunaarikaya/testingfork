import SwiftUI
import LocalAuthentication

struct ProfileView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showingEditProfile = false
    @Environment(\.openURL) private var openURL
    
    private let linkedInURL = URL(string: "https://www.linkedin.com/in/mehmet-tuna-arıkaya-9241b9248/")!
    private let privacyPolicyURL = URL(string: "https://example.com/privacy-policy")!
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profil Başlığı
                HStack(spacing: 16) {
                    // Profil Fotosu
                    if let profileImage = viewModel.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(.blue)
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.user.name)
                            .font(.title3.bold())
                        if let email = viewModel.user.email {
                            Text(email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { showingEditProfile = true }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.05), radius: 5)
                .padding(.horizontal)
                
                // Finansal Özet
                VStack(spacing: 20) {
                    Text("Finansal Özet")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    HStack(spacing: 15) {
                        // Gelir Kartı
                        VStack(spacing: 10) {
                            Circle()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.green)
                                )
                            
                            Text("Toplam Gelir")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text(String(format: "%.2f ₺", viewModel.totalIncome))
                                .font(.headline)
                                .foregroundStyle(.green)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                        
                        // Gider Kartı
                        VStack(spacing: 10) {
                            Circle()
                                .fill(Color.red.opacity(0.2))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "arrow.down.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.red)
                                )
                            
                            Text("Toplam Gider")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text(String(format: "%.2f ₺", viewModel.totalExpense))
                                .font(.headline)
                                .foregroundStyle(.red)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                    }
                    .padding(.horizontal)
                    
                    // Net Durum
                    VStack(spacing: 10) {
                        HStack {
                            Text("Net Durum")
                                .font(.headline)
                            Spacer()
                            Text(String(format: "%.2f ₺", viewModel.totalIncome - viewModel.totalExpense))
                                .font(.title3.bold())
                                .foregroundStyle(viewModel.totalIncome >= viewModel.totalExpense ? .green : .red)
                        }
                        
                        ProgressView(value: min(viewModel.totalIncome / max(viewModel.totalExpense, 1), 1))
                            .tint(viewModel.totalIncome >= viewModel.totalExpense ? .green : .red)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    .padding(.horizontal)
                }
                
                // Ayarlar ve Hakkında
                VStack(spacing: 5) {
                    // Ayarlar
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .font(.title3)
                                .foregroundStyle(.blue)
                            Text("Ayarlar")
                                .font(.headline)
                            Spacer()
                        }
                        
                        Toggle("Karanlık Mod", isOn: $viewModel.isDarkMode)
                            .tint(.blue)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    
                    // Hakkında
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.blue)
                            Text("Hakkında")
                                .font(.headline)
                            Spacer()
                        }
                        
                        Button(action: { openURL(linkedInURL) }) {
                            HStack {
                                Image(systemName: "link.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                                Text("Geliştirici ile İletişim")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "arrow.up.right.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                        }
                        
                        Button(action: { openURL(privacyPolicyURL) }) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                                Text("Gizlilik Sözleşmesi")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "arrow.up.right.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "number.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.blue)
                            Text("Versiyon")
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Profil")
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(viewModel: viewModel)
        }
        .onReceive(NotificationCenter.default.publisher(for: .userProfileUpdated)) { _ in
            viewModel.objectWillChange.send()
        }
    }
} 