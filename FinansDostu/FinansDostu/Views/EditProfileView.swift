import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MainViewModel
    
    @State private var name: String
    @State private var email: String
    @State private var isDarkMode: Bool
    @State private var showingImagePicker = false
    @State private var profileImage: UIImage?
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        _name = State(initialValue: viewModel.user.name)
        _email = State(initialValue: viewModel.user.email ?? "")
        _isDarkMode = State(initialValue: viewModel.isDarkMode)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Profil Fotoğrafı Bölümü
                Section {
                    HStack {
                        Spacer()
                        VStack {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 100))
                                    .foregroundStyle(.blue)
                            }
                            
                            Button(action: { showingImagePicker = true }) {
                                Text("Fotoğraf Değiştir")
                                    .font(.footnote)
                                    .foregroundStyle(.blue)
                            }
                            .padding(.top, 4)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Profil Bilgileri
                Section(header: Text("Profil Bilgileri")) {
                    TextField("Ad Soyad", text: $name)
                        .textContentType(.name)
                    
                    TextField("E-posta", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                // Görünüm Ayarları
                Section(header: Text("Görünüm")) {
                    Toggle("Karanlık Mod", isOn: $isDarkMode)
                }
            }
            .navigationTitle("Profili Düzenle")
            .toolbar {
                toolbarItems
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $profileImage)
        }
    }
    
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("İptal") {
                    dismiss()
                }
                .foregroundStyle(.red)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Kaydet") {
                    saveChanges()
                    dismiss()
                }
                .bold()
                .disabled(name.isEmpty)
            }
        }
    }
    
    private func saveChanges() {
        viewModel.updateUserProfile(
            name: name,
            email: email.isEmpty ? nil : email,
            profileImage: profileImage
        )
        viewModel.isDarkMode = isDarkMode
        
        // Ana sayfadaki hoş geldin mesajını güncellemek için bildirim gönder
        NotificationCenter.default.post(name: .userProfileUpdated, object: nil)
    }
}

// Bildirim adı için extension
extension Notification.Name {
    static let userProfileUpdated = Notification.Name("userProfileUpdated")
}

// Fotoğraf seçici için yardımcı görünüm
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            }
            parent.dismiss()
        }
    }
} 