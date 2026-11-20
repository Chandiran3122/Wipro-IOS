import SwiftUI

struct PartnerProfileView: View {
    @ObservedObject var store: DeliveryStore
    @State private var selectedLanguage: String = "English"
    @State private var preferredNavApp: String = "Apple Maps"
    @State private var soundAlertsEnabled: Bool = true
    @State private var showIDCardModal: Bool = false
    @State private var showPerformanceSheet: Bool = false
    
    private let languages = ["English", "हिंदी (Hindi)", "ಕನ್ನಡ (Kannada)", "தமிழ் (Tamil)", "తెలుగు (Telugu)"]
    
    var body: some View {
        ZStack {
            SwiggyColors.deepNavy
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("PARTNER PORTAL")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(SwiggyColors.orange)
                            Text("Rider Profile")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Digital Swiggy Partner ID Card
                    VStack(spacing: 16) {
                        HStack(alignment: .top) {
                            ZStack {
                                Circle()
                                    .fill(SwiggyColors.orange)
                                    .frame(width: 54, height: 54)
                                Text("RK")
                                    .font(.system(size: 20, weight: .black))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(store.partner.name)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 15))
                                        .foregroundColor(SwiggyColors.emeraldGreen)
                                }
                                
                                Text(store.partner.partnerId)
                                    .font(.system(size: 12, weight: .heavy))
                                    .foregroundColor(SwiggyColors.orange)
                                
                                Text(store.partner.phone)
                                    .font(.system(size: 12))
                                    .foregroundColor(SwiggyColors.mutedText)
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 4) {
                                Image(systemName: "qrcode")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                                Text("VERIFIED")
                                    .font(.system(size: 8, weight: .heavy))
                                    .foregroundColor(SwiggyColors.emeraldGreen)
                            }
                        }
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Vehicle")
                                    .font(.system(size: 10))
                                    .foregroundColor(SwiggyColors.mutedText)
                                Text(store.partner.vehicleType)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Registration No.")
                                    .font(.system(size: 10))
                                    .foregroundColor(SwiggyColors.mutedText)
                                Text(store.partner.vehicleNumber)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(20)
                    .background(SwiggyColors.cardLight)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(SwiggyColors.orange.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // Scorecard & Performance Link
                    Button(action: {
                        showPerformanceSheet = true
                    }) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(SwiggyColors.warningAmber.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "star.fill")
                                    .foregroundColor(SwiggyColors.warningAmber)
                                    .font(.system(size: 16))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Scorecard & Customer Ratings")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Rating: \(String(format: "%.2f", store.partner.rating)) ★ • Top 5% Bengaluru East")
                                    .font(.system(size: 11))
                                    .foregroundColor(SwiggyColors.mutedText)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(SwiggyColors.mutedText)
                        }
                        .padding(14)
                        .background(SwiggyColors.cardLight)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 20)
                    
                    // Vehicle & Equipment Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("EQUIPMENT & VEHICLE")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(SwiggyColors.mutedText)
                        
                        VStack(spacing: 8) {
                            statusRow(title: "Delivery Bag Inspected", value: "Verified Active", icon: "bag.fill", color: SwiggyColors.emeraldGreen)
                            statusRow(title: "Electric Vehicle Battery", value: "\(store.partner.currentBatteryPercentage)% Healthy", icon: "bolt.car.fill", color: .cyan)
                            statusRow(title: "Helmet & Rain Gear", value: "Equipped", icon: "shield.fill", color: SwiggyColors.emeraldGreen)
                            statusRow(title: "Vehicle Insurance", value: "Valid till Dec 2027", icon: "doc.text.fill", color: SwiggyColors.emeraldGreen)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // KYC & Settlement Verification
                    VStack(alignment: .leading, spacing: 12) {
                        Text("KYC & SETTLEMENT VERIFICATION")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(SwiggyColors.mutedText)
                        
                        VStack(spacing: 8) {
                            statusRow(title: "Driving License (MCWG)", value: "Verified", icon: "person.text.rectangle.fill", color: SwiggyColors.emeraldGreen)
                            statusRow(title: "Aadhaar e-KYC", value: "Verified", icon: "lock.shield.fill", color: SwiggyColors.emeraldGreen)
                            statusRow(title: "Bank Account (HDFC)", value: "Active for IMPS", icon: "building.columns.fill", color: SwiggyColors.emeraldGreen)
                            statusRow(title: "FSSAI Food Safety Cert", value: "Certified", icon: "rosette", color: SwiggyColors.emeraldGreen)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // App Preferences
                    VStack(alignment: .leading, spacing: 12) {
                        Text("APP PREFERENCES")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(SwiggyColors.mutedText)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Order Alert Sound & Haptics")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                                Toggle("", isOn: $soundAlertsEnabled)
                                    .toggleStyle(SwitchToggleStyle(tint: SwiggyColors.orange))
                            }
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            HStack {
                                Text("Preferred Navigation App")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                                Picker("Nav App", selection: $preferredNavApp) {
                                    Text("Apple Maps").tag("Apple Maps")
                                    Text("Google Maps").tag("Google Maps")
                                }
                                .pickerStyle(.menu)
                                .tint(SwiggyColors.orange)
                            }
                        }
                        .padding(16)
                        .background(SwiggyColors.cardLight)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 20)
                    
                    // Support & Safety
                    VStack(spacing: 10) {
                        Button(action: {
                            store.showSOSSheet = true
                        }) {
                            HStack {
                                Image(systemName: "exclamationmark.shield.fill")
                                    .foregroundColor(SwiggyColors.alertRed)
                                Text("Emergency SOS & Safety Center")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(SwiggyColors.mutedText)
                            }
                            .padding(16)
                            .background(SwiggyColors.cardLight)
                            .cornerRadius(14)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .sheet(isPresented: $showPerformanceSheet) {
            PerformanceView(store: store)
        }
    }
    
    private func statusRow(title: String, value: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(color)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
            Spacer()
            HStack(spacing: 4) {
                Circle().fill(color).frame(width: 6, height: 6)
                Text(value)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(color)
            }
        }
        .padding(14)
        .background(SwiggyColors.cardLight)
        .cornerRadius(12)
    }
}
