//
//  HealthDataViewModel.swift
//  InstaNutri
//
//  Created by Zeyu Qiu on 11/17/24.
//

import Foundation
import HealthKit

class HealthDataViewModel: ObservableObject {
    private let healthStore = HKHealthStore()

    // Define the types of health data you want to read and write
    let allTypes: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,
        HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
        HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!,
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .height)!,
        HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
    ]

    init() {
        // Automatically request authorization when the view model is created
        requestHealthAuthorization()
    }

    // Function to request HealthKit authorization
    func requestHealthAuthorization() {
        Task {
            do {
                // Check if Health data is available on the device
                if HKHealthStore.isHealthDataAvailable() {
                    try await healthStore.requestAuthorization(toShare: allTypes, read: allTypes)
                    print("HealthKit authorization granted.")
                } else {
                    print("Health data is not available on this device.")
                }
            } catch {
                print("*** An unexpected error occurred while requesting authorization: \(error.localizedDescription) ***")
            }
        }
    }
}
