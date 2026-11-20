import SwiftUI

struct ContentView: View {
    @StateObject private var store = DeliveryStore()
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeDutyView(store: store)
                .tabItem {
                    Label("Duty", systemImage: "bicycle")
                }
                .tag(0)
                .badge(store.incomingOrder != nil ? "1" : (store.activeOrder != nil ? "Active" : nil))
            
            WalletView(store: store)
                .tabItem {
                    Label("Wallet", systemImage: "creditcard.fill")
                }
                .tag(1)
                .badge(store.partner.codCashInHand > 0 ? "COD" : nil)
            
            IncentivesView(store: store)
                .tabItem {
                    Label("Incentives", systemImage: "trophy.fill")
                }
                .tag(2)
                .badge(claimableIncentivesBadge)
            
            EarningsView(store: store)
                .tabItem {
                    Label("Earnings", systemImage: "indianrupeesign.circle.fill")
                }
                .tag(3)
            
            PartnerProfileView(store: store)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(4)
        }
        .tint(SwiggyColors.orange)
        .preferredColorScheme(.dark)
    }
    
    private var claimableIncentivesBadge: String? {
        let count = store.incentiveTargets.filter { $0.isCompleted && !$0.isClaimed }.count
        return count > 0 ? "\(count)" : nil
    }
}

#Preview {
    ContentView()
}
