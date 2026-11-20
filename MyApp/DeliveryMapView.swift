import SwiftUI
import MapKit

struct DeliveryMapView: View {
    let status: DeliveryStatus
    let restaurantName: String
    let customerArea: String
    
    // Default Bengaluru coordinates
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 12.9530, longitude: 77.6100),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    // Locations
    private let restaurantCoord = CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)
    private let customerCoord = CLLocationCoordinate2D(latitude: 12.9352, longitude: 77.6245)
    private let riderCoord = CLLocationCoordinate2D(latitude: 12.9580, longitude: 77.6050)
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(position: $position) {
                // Rider Pin
                Annotation("Rider (You)", coordinate: riderCoord) {
                    ZStack {
                        Circle()
                            .fill(SwiggyColors.orange.opacity(0.3))
                            .frame(width: 44, height: 44)
                        Circle()
                            .fill(SwiggyColors.orange)
                            .frame(width: 30, height: 30)
                            .shadow(radius: 4)
                        Image(systemName: "bicycle")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Restaurant Pin
                Annotation(restaurantName, coordinate: restaurantCoord) {
                    VStack(spacing: 2) {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(SwiggyColors.orange)
                            .background(Circle().fill(Color.white))
                        Text("Pickup")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.75))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
                
                // Customer Pin
                Annotation("Customer", coordinate: customerCoord) {
                    VStack(spacing: 2) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(SwiggyColors.emeraldGreen)
                            .background(Circle().fill(Color.white))
                        Text("Drop")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.75))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            
            // Map floating control badge (Traffic / Live GPS)
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(SwiggyColors.emeraldGreen)
                        .frame(width: 8, height: 8)
                    Text("GPS High Accuracy")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.75))
                .cornerRadius(20)
                .padding([.top, .trailing], 12)
            }
        }
    }
}
