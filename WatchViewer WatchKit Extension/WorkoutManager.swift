//
//  WorkoutManager.swift
//  soloWatchApp WatchKit Extension
//
//  Created by Petar Petkov on 22/02/2020.
//  Copyright © 2020 Petar Petkov. All rights reserved.
//

import Foundation
import HealthKit
import CoreMotion

/**
 `WorkoutManagerDelegate` exists to inform delegates of swing data changes.
 These updates can be used to populate the user interface.
 */
protocol WorkoutManagerDelegate: class {
    func didUpdateForehandSwingCount(_ manager: WorkoutManager, forehandCount: Int)
    func didUpdateBackhandSwingCount(_ manager: WorkoutManager, backhandCount: Int)
    func didUpdateAtitude(_ manager: WorkoutManager, atitude: CMAttitude)
}

class WorkoutManager: MotionManagerDelegate {
    // MARK: Properties
    let motionManager = MotionManager()
    let healthStore = HKHealthStore()

    weak var delegate: WorkoutManagerDelegate?
    var session: HKWorkoutSession?

    // MARK: Initialization
    
    init() {
        motionManager.delegate = self
    }

    // MARK: WorkoutManager
    
    func startWorkout() {
        // If we have already started the workout, then do nothing.
        if (session != nil) {
            return
        }
        
        let healthStore = HKHealthStore()
        
        // Configure the workout session.
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .tennis
        workoutConfiguration.locationType = .outdoor
        
        do {
            if #available(watchOSApplicationExtension 5.0, *) {
                session = try HKWorkoutSession(healthStore: healthStore, configuration: workoutConfiguration)
            } else {
                session = try HKWorkoutSession(configuration: workoutConfiguration)
            }
        } catch {
            fatalError("Unable to create the workout session!")
        }

        // Start the workout session and device motion updates.
        if #available(watchOSApplicationExtension 5.0, *) {
            session?.startActivity(with: Date.init())
        } else {
            healthStore.start(session!)
        }
        
        motionManager.startUpdates()
    }

    func stopWorkout() {
        // If we have already stopped the workout, then do nothing.
        if (session == nil) {
            return
        }

        // Stop the device motion updates and workout session.
        motionManager.stopUpdates()
        if #available(watchOSApplicationExtension 5.0, *) {
            session?.end()
        } else {
            healthStore.end(session!)
        }

        // Clear the workout session.
        session = nil
    }

    // MARK: MotionManagerDelegate
    func didUpdateAtitude(_ manager: MotionManager, atitude: CMAttitude) {
        delegate?.didUpdateAtitude(self, atitude: atitude)
    }
    
    func didUpdateForehandSwingCount(_ manager: MotionManager, forehandCount: Int) {
        delegate?.didUpdateForehandSwingCount(self, forehandCount: forehandCount)
    }

    func didUpdateBackhandSwingCount(_ manager: MotionManager, backhandCount: Int) {
        delegate?.didUpdateBackhandSwingCount(self, backhandCount: backhandCount)
    }
}


