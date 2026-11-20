import SwiftUI

struct ActiveOrderView: View {
    @ObservedObject var store: DeliveryStore
    let order: DeliveryOrder
    
    @State private var otpInput: String = ""
    @State private var otpError: Bool = false
    @State private var codCollected: Bool = false
    @State private var showCallConfirmation: Bool = false
    @State private var callTarget: String = ""
    @State private var callNumber: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Live Status Stepper Bar
            deliveryStatusBar
            
            // Interactive Map View
            DeliveryMapView(
                status: order.status,
                restaurantName: order.restaurantName,
                customerArea: order.customerAddress.components(separatedBy: ",").first ?? "Drop Location"
            )
            .frame(height: 220)
            
            // Phase-Specific Content Sheet
            ScrollView {
                VStack(spacing: 16) {
                    switch order.status {
                    case .navigatingToRestaurant:
                        navigatingToRestaurantView
                    case .atRestaurant:
                        atRestaurantPickupView
                    case .outForDelivery:
                        outForDeliveryView
                    case .atCustomerLocation:
                        atCustomerVerificationView
                    default:
                        EmptyView()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .background(SwiggyColors.deepNavy)
            
            // Bottom Swipe Action Slider
            bottomSliderAction
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(SwiggyColors.cardBackground)
        }
        .background(SwiggyColors.deepNavy)
        .alert(isPresented: $showCallConfirmation) {
            Alert(
                title: Text("Contact \(callTarget)"),
                message: Text("Connecting via Swiggy secure number masking to \(callNumber)"),
                primaryButton: .default(Text("Call Now")),
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: - Delivery Status Stepper
    private var deliveryStatusBar: some View {
        HStack(spacing: 4) {
            ForEach(1...4, id: \.self) { step in
                let currentStep = order.status.stepIndex
                let isPassed = currentStep >= step
                let isCurrent = currentStep == step
                
                VStack(spacing: 4) {
                    Capsule()
                        .fill(isPassed ? SwiggyColors.orange : Color.white.opacity(0.15))
                        .frame(height: 4)
                    
                    Text(stepLabel(step))
                        .font(.system(size: 10, weight: isCurrent ? .bold : .medium))
                        .foregroundColor(isCurrent ? SwiggyColors.orange : (isPassed ? .white : SwiggyColors.mutedText))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(SwiggyColors.cardBackground)
    }
    
    private func stepLabel(_ step: Int) -> String {
        switch step {
        case 1: return "Reach Rest."
        case 2: return "Pickup"
        case 3: return "On Way"
        case 4: return "Deliver"
        default: return ""
        }
    }
    
    // MARK: - Phase 1: Navigating to Restaurant
    private var navigatingToRestaurantView: some View {
        VStack(spacing: 14) {
            // Destination Card
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("NAVIGATING TO RESTAURANT", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(SwiggyColors.orange)
                    Spacer()
                    Text("ETA: 6 mins")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(order.restaurantName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(order.restaurantAddress)
                    .font(.system(size: 13))
                    .foregroundColor(SwiggyColors.mutedText)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SwiggyColors.cardLight)
            .cornerRadius(14)
            
            // Quick Action Buttons
            HStack(spacing: 12) {
                actionIconButton(icon: "phone.fill", label: "Call Restaurant", color: SwiggyColors.orange) {
                    callTarget = order.restaurantName
                    callNumber = order.restaurantPhone
                    showCallConfirmation = true
                }
                
                actionIconButton(icon: "map.fill", label: "Navigate", color: SwiggyColors.emeraldGreen) {
                    HapticManager.playImpact(style: .medium)
                }
                
                actionIconButton(icon: "exclamationmark.triangle.fill", label: "Issue", color: SwiggyColors.warningAmber) {
                    store.showSupportSheet = true
                }
            }
        }
    }
    
    // MARK: - Phase 2: At Restaurant Pickup
    private var atRestaurantPickupView: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("ORDER PICKUP CHECKLIST", systemImage: "bag.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(SwiggyColors.orange)
                    Spacer()
                    Text(order.orderNumber)
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(6)
                }
                
                Text("Confirm items packed before moving:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(SwiggyColors.mutedText)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SwiggyColors.cardLight)
            .cornerRadius(14)
            
            // Items Checklist
            VStack(spacing: 8) {
                ForEach(order.items) { item in
                    Button(action: {
                        store.toggleItemVerification(itemId: item.id)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: item.isVerified ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22))
                                .foregroundColor(item.isVerified ? SwiggyColors.emeraldGreen : SwiggyColors.mutedText)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Circle()
                                        .fill(item.isVeg ? SwiggyColors.emeraldGreen : SwiggyColors.alertRed)
                                        .frame(width: 8, height: 8)
                                    Text("\(item.quantity)x \(item.name)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                
                                if let note = item.specialInstructions {
                                    Text("Note: \(note)")
                                        .font(.system(size: 11))
                                        .foregroundColor(SwiggyColors.warningAmber)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(14)
                        .background(SwiggyColors.cardLight)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                
                Button(action: {
                    store.verifyAllItems()
                }) {
                    Text("Select All Items Checked")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(SwiggyColors.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            }
        }
    }
    
    // MARK: - Phase 3: Out For Delivery
    private var outForDeliveryView: some View {
        VStack(spacing: 14) {
            // Customer Destination Card
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("DELIVERING TO CUSTOMER", systemImage: "figure.walk")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(SwiggyColors.emeraldGreen)
                    Spacer()
                    Text("ETA: 12 mins")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(order.customerName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(order.customerAddress)
                    .font(.system(size: 13))
                    .foregroundColor(SwiggyColors.mutedText)
                
                if let instructions = order.customerInstructions {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "bell.slash.fill")
                            .foregroundColor(SwiggyColors.warningAmber)
                            .font(.system(size: 13))
                        Text(instructions)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(SwiggyColors.warningAmber.opacity(0.12))
                    .cornerRadius(8)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SwiggyColors.cardLight)
            .cornerRadius(14)
            
            // Contact Buttons
            HStack(spacing: 12) {
                actionIconButton(icon: "phone.fill", label: "Call Customer", color: SwiggyColors.emeraldGreen) {
                    callTarget = order.customerName
                    callNumber = order.customerPhone
                    showCallConfirmation = true
                }
                
                actionIconButton(icon: "message.fill", label: "Chat", color: SwiggyColors.orange) {
                    HapticManager.playImpact(style: .medium)
                }
                
                actionIconButton(icon: "map.fill", label: "Directions", color: .blue) {
                    HapticManager.playImpact(style: .medium)
                }
            }
        }
    }
    
    // MARK: - Phase 4: At Customer Location & Verification
    private var atCustomerVerificationView: some View {
        VStack(spacing: 14) {
            // Delivery Verification Card
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("FINAL STEP: VERIFY DELIVERY", systemImage: "checkmark.shield.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(SwiggyColors.emeraldGreen)
                    Spacer()
                    Text(order.orderNumber)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Ask customer for the 4-digit Delivery OTP:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(SwiggyColors.mutedText)
                
                // OTP Input Field
                HStack(spacing: 8) {
                    TextField("Enter 4-digit OTP", text: $otpInput)
                        .keyboardType(.numberPad)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    
                    // Demo helper button
                    Button(action: {
                        otpInput = order.otpCode
                    }) {
                        Text("Autofill (\(order.otpCode))")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(SwiggyColors.orange)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 12)
                            .background(SwiggyColors.orange.opacity(0.15))
                            .cornerRadius(10)
                    }
                }
                
                if otpError {
                    Text("Incorrect OTP. Please check with customer or try again.")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(SwiggyColors.alertRed)
                }
            }
            .padding(16)
            .background(SwiggyColors.cardLight)
            .cornerRadius(14)
            
            // Cash On Delivery Card (if applicable)
            if order.paymentMode == .cashOnDelivery {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "indianrupeesign.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(SwiggyColors.warningAmber)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CASH ON DELIVERY")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(SwiggyColors.warningAmber)
                            Text("Collect ₹\(Int(order.codAmount)) from customer")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    
                    Toggle(isOn: $codCollected) {
                        Text("I have received ₹\(Int(order.codAmount)) in cash/UPI")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: SwiggyColors.emeraldGreen))
                }
                .padding(16)
                .background(SwiggyColors.warningAmber.opacity(0.12))
                .cornerRadius(14)
            }
        }
    }
    
    // MARK: - Action Icon Button Helper
    private func actionIconButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(SwiggyColors.cardLight)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Bottom Slider Action
    @ViewBuilder
    private var bottomSliderAction: some View {
        switch order.status {
        case .navigatingToRestaurant:
            SwipeActionButton(
                title: "Slide to Arrive at Restaurant",
                subtitle: order.restaurantName,
                iconName: "arrow.right",
                sliderColor: SwiggyColors.orange
            ) {
                store.markArrivedAtRestaurant()
            }
            
        case .atRestaurant:
            let allChecked = order.items.allSatisfy { $0.isVerified }
            SwipeActionButton(
                title: allChecked ? "Slide to Confirm Pickup" : "Check items & Slide",
                subtitle: "\(order.items.count) items packed",
                iconName: "bag.fill",
                sliderColor: allChecked ? SwiggyColors.emeraldGreen : SwiggyColors.orange
            ) {
                store.confirmOrderPickedUp()
            }
            
        case .outForDelivery:
            SwipeActionButton(
                title: "Slide to Arrive at Customer",
                subtitle: order.customerAddress.components(separatedBy: ",").first,
                iconName: "arrow.right",
                sliderColor: SwiggyColors.orange
            ) {
                store.markArrivedAtCustomer()
            }
            
        case .atCustomerLocation:
            Button(action: {
                let success = store.completeDelivery(enteredOtp: otpInput)
                if !success {
                    otpError = true
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 18))
                    Text("VERIFY & DELIVER ORDER")
                        .font(.system(size: 15, weight: .heavy))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(SwiggyColors.emeraldGreen)
                .cornerRadius(16)
                .shadow(color: SwiggyColors.emeraldGreen.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            
        default:
            EmptyView()
        }
    }
}
