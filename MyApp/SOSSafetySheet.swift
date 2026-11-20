import SwiftUI

struct SOSSafetySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var sosTriggered: Bool = false
    @State private var showCallAlert: Bool = false
    @State private var selectedEmergencyNumber: String = ""
    @State private var selectedEmergencyName: String = ""
    
    var body: some View {
        ZStack {
            SwiggyColors.deepNavy
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("EMERGENCY & SAFETY")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(SwiggyColors.alertRed)
                        Text("Swiggy Rider Shield 24x7")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(SwiggyColors.mutedText)
                    }
                }
                .padding(.top, 20)
                
                // One-Touch SOS Alert
                VStack(spacing: 12) {
                    Button(action: {
                        sosTriggered.toggle()
                        HapticManager.playNotification(type: .error)
                    }) {
                        ZStack {
                            Circle()
                                .fill(SwiggyColors.alertRed.opacity(0.2))
                                .frame(width: 110, height: 110)
                            Circle()
                                .fill(SwiggyColors.alertRed)
                                .frame(width: 80, height: 80)
                                .shadow(color: SwiggyColors.alertRed.opacity(0.6), radius: 10)
                            
                            VStack(spacing: 2) {
                                Image(systemName: "bell.badge.fill")
                                    .font(.system(size: 24))
                                Text("SOS")
                                    .font(.system(size: 14, weight: .black))
                            }
                            .foregroundColor(.white)
                        }
                    }
                    
                    Text(sosTriggered ? "SOS Alert Broadcasted to Swiggy Rapid Response Team!" : "Tap for Immediate Assistance")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(sosTriggered ? SwiggyColors.emeraldGreen : .white)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(SwiggyColors.cardLight)
                .cornerRadius(18)
                
                // Quick Call Contacts
                VStack(spacing: 10) {
                    emergencyContactRow(
                        title: "Swiggy Rider Safety Hotline",
                        subtitle: "Toll-free 24x7 support dedicated to partners",
                        number: "1800-208-7844",
                        icon: "phone.bubble.left.fill",
                        color: SwiggyColors.orange
                    )
                    
                    emergencyContactRow(
                        title: "Police Emergency",
                        subtitle: "Direct line to local emergency services",
                        number: "112",
                        icon: "shield.fill",
                        color: .blue
                    )
                    
                    emergencyContactRow(
                        title: "Medical & Ambulance",
                        subtitle: "National Emergency Ambulance Service",
                        number: "108",
                        icon: "cross.case.fill",
                        color: SwiggyColors.alertRed
                    )
                    
                    emergencyContactRow(
                        title: "Rider Roadside Assistance",
                        subtitle: "Flat tire, battery swap, towing support",
                        number: "1800-419-0022",
                        icon: "wrench.and.screwdriver.fill",
                        color: SwiggyColors.warningAmber
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .alert(isPresented: $showCallAlert) {
            Alert(
                title: Text("Call \(selectedEmergencyName)?"),
                message: Text("Emergency dial to \(selectedEmergencyNumber)"),
                primaryButton: .destructive(Text("Call \(selectedEmergencyNumber)")),
                secondaryButton: .cancel()
            )
        }
    }
    
    private func emergencyContactRow(title: String, subtitle: String, number: String, icon: String, color: Color) -> some View {
        Button(action: {
            selectedEmergencyName = title
            selectedEmergencyNumber = number
            showCallAlert = true
            HapticManager.playImpact(style: .heavy)
        }) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(SwiggyColors.mutedText)
                }
                
                Spacer()
                
                Text("CALL")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(color.opacity(0.15))
                    .cornerRadius(8)
            }
            .padding(14)
            .background(SwiggyColors.cardLight)
            .cornerRadius(14)
        }
    }
}
