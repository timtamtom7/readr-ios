import SwiftUI

/// R8: Cross-device sync settings view
struct ReadrCrossDeviceSyncView: View {
    @StateObject private var syncService = ReadrCrossDeviceSyncService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        syncStatusCard
                        devicesSection
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Sync")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var syncStatusCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("iCloud Sync")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(DesignTokens.primaryText)

                    Text(syncService.lastSyncText)
                        .font(.system(size: 13))
                        .foregroundColor(DesignTokens.secondaryText)
                }

                Spacer()

                if syncService.isSyncing {
                    ProgressView()
                        .tint(DesignTokens.accent)
                } else {
                    Button {
                        Task {
                            try? await syncService.syncAll()
                        }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 18))
                            .foregroundColor(DesignTokens.accent)
                    }
                }
            }
        }
        .padding(16)
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var devicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Devices")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(DesignTokens.primaryText)

            if syncService.connectedDevices.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "iphone.and.arrow.forward")
                        .font(.system(size: 40))
                        .foregroundColor(DesignTokens.secondaryText)

                    Text("No devices connected")
                        .font(.system(size: 15))
                        .foregroundColor(DesignTokens.secondaryText)

                    Text("Sign in with the same Apple ID on other devices to sync your library.")
                        .font(.system(size: 13))
                        .foregroundColor(DesignTokens.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(DesignTokens.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                ForEach(syncService.connectedDevices) { device in
                    deviceRow(device)
                }
            }
        }
    }

    private func deviceRow(_ device: ReadrCrossDeviceSyncService.Device) -> some View {
        HStack(spacing: 12) {
            Image(systemName: deviceIcon(device.type))
                .font(.system(size: 20))
                .foregroundColor(device.isConnected ? DesignTokens.accent : DesignTokens.secondaryText)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(device.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(DesignTokens.primaryText)

                Text(device.isConnected ? "Connected" : "Last seen recently")
                    .font(.system(size: 12))
                    .foregroundColor(DesignTokens.secondaryText)
            }

            Spacer()

            if device.isConnected {
                Circle()
                    .fill(DesignTokens.accent)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(12)
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func deviceIcon(_ type: ReadrCrossDeviceSyncService.Device.DeviceType) -> String {
        switch type {
        case .iPhone: return "iphone"
        case .iPad: return "ipad"
        case .mac: return "laptopcomputer"
        case .appleWatch: return "applewatch"
        }
    }
}
