//
//  HealthDataViewModel.swift
//  InstaNutri
//
//  Created by Zeyu Qiu on 11/17/24.
//

import Foundation
import HealthKit
import UIKit


class HealthDataViewModel: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var showHealthSettingsAlert = false


    // Define the types of health data you want to read
    let readTypes: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .bodyMass)!, // Weight
        HKObjectType.quantityType(forIdentifier: .height)!    // Height
    ]

    // Define the types of health data you want to write
    let writeTypes: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!, // Total Calories
        HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,         // Protein
        HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,  // Carbohydrates
        HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!        // Fat Total
    ]

    // Request HealthKit authorization
    func requestHealthAuthorization() {
        Task {
            do {
                if HKHealthStore.isHealthDataAvailable() {
                    let readStatus = try await checkAuthorizationStatus()

                    if readStatus == .notDetermined {
                        // Request authorization for read and write separately
                        try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
                        print("HealthKit authorization granted.")
                    } else {
                        // Permissions already configured, direct to Health settings
                        DispatchQueue.main.async {
                            self.showHealthSettingsAlert = true
                        }
                    }
                } else {
                    print("Health data is not available on this device.")
                }
            } catch {
                print("*** An unexpected error occurred while requesting authorization: \(error.localizedDescription) ***")
            }
        }
    }

    // Check current authorization status (example for one type)
    private func checkAuthorizationStatus() async throws -> HKAuthorizationStatus {
        let sampleType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        return healthStore.authorizationStatus(for: sampleType)
    }

    // Open Health settings
    func openHealthSettings() {
        if let url = URL(string: "x-apple-health://") {
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func writeMealData(_ meal: Meal, completion: @escaping (Bool, Error?) -> Void) {
        guard let dietaryEnergy = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed),
              let dietaryProtein = HKQuantityType.quantityType(forIdentifier: .dietaryProtein),
              let dietaryFatTotal = HKQuantityType.quantityType(forIdentifier: .dietaryFatTotal),
              let dietaryCarbohydrates = HKQuantityType.quantityType(forIdentifier: .dietaryCarbohydrates) else {
            completion(false, NSError(domain: "HealthKitError", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit data types are unavailable."]))
            return
        }

        let calorieQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: meal.totalCalories)
        let proteinQuantity = HKQuantity(unit: .gram(), doubleValue: meal.totalProtein)
        let fatQuantity = HKQuantity(unit: .gram(), doubleValue: meal.totalFats)
        let carbQuantity = HKQuantity(unit: .gram(), doubleValue: meal.totalCarbs)

        let now = Date()

        let calorieSample = HKQuantitySample(type: dietaryEnergy, quantity: calorieQuantity, start: now, end: now)
        let proteinSample = HKQuantitySample(type: dietaryProtein, quantity: proteinQuantity, start: now, end: now)
        let fatSample = HKQuantitySample(type: dietaryFatTotal, quantity: fatQuantity, start: now, end: now)
        let carbSample = HKQuantitySample(type: dietaryCarbohydrates, quantity: carbQuantity, start: now, end: now)

        healthStore.save([calorieSample, proteinSample, fatSample, carbSample]) { success, error in
            completion(success, error)
        }
    }
}
