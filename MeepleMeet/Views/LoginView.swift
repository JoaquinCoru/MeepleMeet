import SwiftUI

struct LoginView: View {
    @Environment(AuthVM.self) private var authViewModel
    private enum Field: Hashable {
        case displayName
        case email
        case password
    }

    @State private var isCreatingAccount = false
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var showingComingSoon = false
    @State private var registrationAlert: RegistrationAlert?
    @FocusState private var focusedField: Field?

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                brandHeader
                formCard
                footerNote
            }
            .padding(.horizontal, 22)
            .padding(.top, 28)
            .padding(.bottom, 32)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .alert("Muy pronto", isPresented: $showingComingSoon) {
            Button("Entendido", role: .cancel) { }
        } message: {
            Text("La recuperación de contraseña estará disponible próximamente.")
        }
        .alert(item: $registrationAlert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("Entendido"))
            )
        }
    }

    private var brandHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.sand)
                    .frame(width: 76, height: 76)
                Image(systemName: "dice.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.accent)
                    .rotationEffect(.degrees(-8))
            }

            VStack(spacing: 7) {
                Text("MeepleMeet")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(isCreatingAccount
                     ? "Crea tu cuenta y encuentra tu próxima mesa."
                     : "Entra en tu cuenta y vuelve a la mesa.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 5) {
                Text(isCreatingAccount ? "Crear cuenta" : "Iniciar sesión")
                    .font(.title2.bold())
                Text(isCreatingAccount
                     ? "Un perfil para tus juegos y quedadas."
                     : "Nos alegra tenerte de vuelta.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 15) {
                if isCreatingAccount {
                    inputField(title: "Nombre", symbol: "person") {
                        TextField("Cómo te llamamos", text: $displayName)
                            .textContentType(.name)
                            .textInputAutocapitalization(.words)
                            .focused($focusedField, equals: .displayName)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                inputField(title: "Correo electrónico", symbol: "envelope") {
                    TextField("tu@email.com", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .email)
                }

                inputField(title: "Contraseña", symbol: "lock") {
                    HStack(spacing: 10) {
                        Group {
                            if isPasswordVisible {
                                TextField("Tu contraseña", text: $password)
                            } else {
                                SecureField("Tu contraseña", text: $password)
                            }
                        }
                        .textContentType(isCreatingAccount ? .newPassword : .password)
                        .focused($focusedField, equals: .password)

                        Button {
                            isPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityLabel(isPasswordVisible ? "Ocultar contraseña" : "Mostrar contraseña")
                    }
                }
            }

            if !isCreatingAccount {
                HStack {
                    Spacer()
                    Button("¿Has olvidado tu contraseña?") { showingComingSoon = true }
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.accent)
                }
                .padding(.top, -8)
            }

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button {
                focusedField = nil
                Task {
                    if isCreatingAccount {
                        let succeeded = await authViewModel.register(
                            name: displayName,
                            email: email,
                            password: password
                        )
                        registrationAlert = succeeded
                            ? RegistrationAlert(title: "Cuenta creada", message: "Tu cuenta se ha creado correctamente. Ya puedes iniciar sesión.")
                            : RegistrationAlert(title: "No se pudo crear la cuenta", message: "Comprueba los datos. Es posible que el correo ya esté registrado o que la contraseña tenga menos de 8 caracteres.")
                    } else {
                        await authViewModel.login(email: email, password: password)
                    }
                }
            } label: {
                HStack(spacing: 9) {
                    if authViewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(isCreatingAccount ? "Crear cuenta" : "Iniciar sesión")
                        Image(systemName: "arrow.right")
                    }
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(authViewModel.isLoading || (isCreatingAccount
                ? !canRegister
                : email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || password.isEmpty))
            .opacity(authViewModel.isLoading ? 0.75 : 1)
            .padding(.top, 2)

            HStack(spacing: 5) {
                Text(isCreatingAccount ? "¿Ya tienes cuenta?" : "¿Aún no tienes cuenta?")
                    .foregroundStyle(.secondary)
                Button(isCreatingAccount ? "Inicia sesión" : "Regístrate") {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        isCreatingAccount.toggle()
                        password = ""
                        focusedField = nil
                    }
                }
                .fontWeight(.semibold)
                .foregroundStyle(.accent)
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .padding(.top, 1)
        }
        .padding(22)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(uiColor: .separator).opacity(0.22), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 18, y: 8)
    }

    private var canRegister: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }

    private func inputField<Field: View>(
        title: String,
        symbol: String,
        @ViewBuilder field: () -> Field
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            HStack(spacing: 11) {
                Image(systemName: symbol)
                    .font(.subheadline)
                    .foregroundStyle(.accent)
                    .frame(width: 19)
                field()
                    .font(.body)
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .textInputAutocapitalization(.never)
            .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(uiColor: .separator).opacity(0.25), lineWidth: 1)
            }
        }
    }

    private var footerNote: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "person.3.fill")
                .foregroundStyle(.accent)
            Text("Organiza partidas, descubre juegos y comparte tu ludoteca con tu comunidad.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
        .font(.footnote)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
    }
}

private struct RegistrationAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
