import SwiftUI

struct IncentivesView: View {
    @ObservedObject var store: DeliveryStore
    @State private var selectedTab: String = "Active Targets"
    
    private let tabs = ["Active Targets", "Tier Ladder", "Guidelines"]
    
    var body: some View {
        ZStack {
            SwiggyColors.deepNavy
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("TARGETS & REWARDS")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(SwiggyColors.orange)
                            Text("Partner Incentives")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        
                        // Badge count of ready-to-claim incentives
                        if claimableCount > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 11))
                                Text("\(claimableCount) Ready to Claim")
                                    .font(.system(size: 11, weight: .heavy))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(SwiggyColors.emeraldGreen)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Hero Incentive Banner
                    heroIncentiveBanner
                        .padding(.horizontal, 20)
                    
                    // Claimable Ready Section (if any)
                    ForEach(store.incentiveTargets.filter { $0.isCompleted && !$0.isClaimed }) { target in
                        claimableIncentiveCard(target: target)
                            .padding(.horizontal, 20)
                    }
                    
                    // Sub-navigation segment control
                    HStack(spacing: 8) {
                        ForEach(tabs, id: \.self) { tab in
                            Button(action: {
                                selectedTab = tab
                                HapticManager.playImpact(style: .light)
                            }) {
                                Text(tab)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(selectedTab == tab ? .white : SwiggyColors.mutedText)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(selectedTab == tab ? SwiggyColors.orange : SwiggyColors.cardLight)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Tab content
                    switch selectedTab {
                    case "Active Targets":
                        activeTargetsContent
                    case "Tier Ladder":
                        tierLadderContent
                    case "Guidelines":
                        guidelinesContent
                    default:
                        EmptyView()
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    private var claimableCount: Int {
        store.incentiveTargets.filter { $0.isCompleted && !$0.isClaimed }.count
    }
    
    // MARK: - Hero Banner
    private var heroIncentiveBanner: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(SwiggyColors.warningAmber)
                        Text("WEEKEND SURGE BONUSES")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(SwiggyColors.warningAmber)
                    }
                    Text("Earn Extra ₹3,080 This Week")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(SwiggyColors.orange.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 24))
                        .foregroundColor(SwiggyColors.warningAmber)
                }
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Bonuses Claimed")
                        .font(.system(size: 11))
                        .foregroundColor(SwiggyColors.mutedText)
                    Text("₹450")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(SwiggyColors.emeraldGreen)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Potential Unlocked")
                        .font(.system(size: 11))
                        .foregroundColor(SwiggyColors.mutedText)
                    Text("7 / 10 Trips Done")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color(red: 48/255, green: 58/255, blue: 76/255), Color(red: 32/255, green: 40/255, blue: 54/255)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(SwiggyColors.warningAmber.opacity(0.3), lineWidth: 1.5)
        )
    }
    
    // MARK: - Claimable Incentive Card
    private func claimableIncentiveCard(target: IncentiveTarget) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(SwiggyColors.emeraldGreen.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: "gift.fill")
                        .font(.system(size: 20))
                        .foregroundColor(SwiggyColors.emeraldGreen)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("TARGET ACHIEVED!")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(SwiggyColors.emeraldGreen)
                        Text("• \(target.tier)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(SwiggyColors.mutedText)
                    }
                    Text(target.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("+₹\(Int(target.bonusAmount))")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(SwiggyColors.emeraldGreen)
            }
            
            Button(action: {
                store.claimIncentive(targetId: target.id)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 16))
                    Text("CLAIM ₹\(Int(target.bonusAmount)) TO WALLET")
                        .font(.system(size: 13, weight: .heavy))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(SwiggyColors.emeraldGreen)
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(SwiggyColors.cardLight)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(SwiggyColors.emeraldGreen, lineWidth: 1.5)
        )
        .shadow(color: SwiggyColors.emeraldGreen.opacity(0.3), radius: 8)
    }
    
    // MARK: - Active Targets Tab
    private var activeTargetsContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(store.incentiveTargets) { target in
                targetDetailCard(target: target)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func targetDetailCard(target: IncentiveTarget) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(target.tier.uppercased())
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(SwiggyColors.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(SwiggyColors.orange.opacity(0.15))
                            .cornerRadius(4)
                        
                        if target.isClaimed {
                            Text("CLAIMED")
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(SwiggyColors.emeraldGreen)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(SwiggyColors.emeraldGreen.opacity(0.15))
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(target.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(target.description)
                        .font(.system(size: 11))
                        .foregroundColor(SwiggyColors.mutedText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("₹\(Int(target.bonusAmount))")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(target.isClaimed ? SwiggyColors.mutedText : SwiggyColors.warningAmber)
                    Text("Reward")
                        .font(.system(size: 10))
                        .foregroundColor(SwiggyColors.mutedText)
                }
            }
            
            // Progress Bar
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)
                        Capsule()
                            .fill(target.isCompleted ? SwiggyColors.emeraldGreen : SwiggyColors.orange)
                            .frame(width: geo.size.width * CGFloat(target.progress), height: 8)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text("\(target.completedOrders)/\(target.targetOrders) completed")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(target.isCompleted ? SwiggyColors.emeraldGreen : .white)
                    
                    Spacer()
                    
                    if target.isCompleted {
                        Text("Target Met!")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(SwiggyColors.emeraldGreen)
                    } else {
                        let remaining = target.targetOrders - target.completedOrders
                        Text("\(remaining) more orders needed")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(SwiggyColors.warningAmber)
                    }
                }
            }
            
            Divider().background(Color.white.opacity(0.08))
            
            // Criteria Pills & Deadline
            HStack {
                HStack(spacing: 6) {
                    ForEach(target.criteria, id: \.self) { c in
                        Text(c)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(SwiggyColors.mutedText)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text(target.deadline)
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(SwiggyColors.mutedText)
            }
        }
        .padding(16)
        .background(SwiggyColors.cardLight)
        .cornerRadius(16)
    }
    
    // MARK: - Tier Ladder Tab
    private var tierLadderContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("DAILY TRIPS MILESTONE REWARD LADDER")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(SwiggyColors.mutedText)
            
            ladderStep(tierName: "Bronze Starter", trips: "5 Deliveries", bonus: "₹80 Bonus", isCurrent: false, isCompleted: true)
            ladderStep(tierName: "Silver Champion", trips: "10 Deliveries", bonus: "₹200 Bonus", isCurrent: true, isCompleted: false)
            ladderStep(tierName: "Gold Superstar", trips: "15 Deliveries", bonus: "₹450 Bonus", isCurrent: false, isCompleted: false)
            ladderStep(tierName: "Diamond Legend", trips: "20 Deliveries", bonus: "₹800 Bonus", isCurrent: false, isCompleted: false)
        }
        .padding(.horizontal, 20)
    }
    
    private func ladderStep(tierName: String, trips: String, bonus: String, isCurrent: Bool, isCompleted: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isCompleted ? SwiggyColors.emeraldGreen : (isCurrent ? SwiggyColors.orange : Color.white.opacity(0.1)))
                    .frame(width: 36, height: 36)
                Image(systemName: isCompleted ? "checkmark" : (isCurrent ? "play.fill" : "lock.fill"))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(tierName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text(trips)
                    .font(.system(size: 11))
                    .foregroundColor(SwiggyColors.mutedText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(bonus)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(isCompleted ? SwiggyColors.emeraldGreen : (isCurrent ? SwiggyColors.warningAmber : SwiggyColors.mutedText))
                if isCurrent {
                    Text("In Progress (7/10)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(SwiggyColors.orange)
                }
            }
        }
        .padding(14)
        .background(SwiggyColors.cardLight)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isCurrent ? SwiggyColors.orange.opacity(0.5) : Color.clear, lineWidth: 1.5)
        )
    }
    
    // MARK: - Guidelines Tab
    private var guidelinesContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SWIGGY INCENTIVE ELIGIBILITY CRITERIA")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(SwiggyColors.mutedText)
            
            guidelineRow(icon: "checkmark.seal.fill", title: "Acceptance Rate ≥ 90%", desc: "Maintain at least 90% order acceptance rate during peak shift hours.")
            guidelineRow(icon: "shield.fill", title: "Zero Rider Cancellations", desc: "No partner-initiated cancellations allowed on peak incentive orders.")
            guidelineRow(icon: "wallet.pass.fill", title: "Instant Wallet Payout", desc: "Claimed bonuses are credited instantly to your Swiggy Partner Wallet and can be cashed out immediately.")
            guidelineRow(icon: "percent", title: "0% Commission Deduction", desc: "Swiggy does not take any commission on incentives or tips. 100% of the bonus is yours.")
        }
        .padding(.horizontal, 20)
    }
    
    private func guidelineRow(icon: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(SwiggyColors.orange)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 11))
                    .foregroundColor(SwiggyColors.mutedText)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SwiggyColors.cardLight)
        .cornerRadius(12)
    }
}
