//
//  AppBrain.swift
//  Reef
//
//  Created by Conor Sheehan on 8/18/18.
//  Copyright © 2018 Infinitry. All rights reserved.
//

import Foundation
import Firebase
import CSVImporter

class AppBrain {

  let UDkeys = UserDefaultKeys()
  let defaults = UserDefaults.standard

  // Stores all userDefault key Strings for deep internal storage
  struct UserDefaultKeys {
  }

  // Firebase ACcess
  var userUID = Auth.auth().currentUser?.uid // User's firebase Unique Identifier
  
  enum GrowTrackerBranch: String { case currentGrowStage, growTasksComplete, allGrows = "AllGrows", completedGrows,
                                    currentSetupStage, setupTasksComplete }
  enum EcosystemBranch: String { case setup, addedFish, cyclingComplete }
  enum AllGrowsBranch: String { case germinated, seedling, vegetative, flowering, harvest, drying, complete,
                                strainName, strainType, seedType }
  enum SensorBranch: String { case airTemp, humidity, plantHeight, waterLevel, waterTemp }
  enum ReefSettingsBranch: String { case growStage, lastConnected, ssid, sunrise }
  enum ReefScriptsBranch: String { case waterLevel, fillingTank, testSensors}

  // Firebase Database References for quick access to database structures
  var databaseRef: DatabaseReference?
  var userDataRef: DatabaseReference?
  var growTrackerRef: DatabaseReference?
  var sensorDataRef: DatabaseReference?
  var ecosystemRef: DatabaseReference?
  var reefSettingsRef: DatabaseReference?
  var allGrowsRef: DatabaseReference?
  var reefScriptsRef: DatabaseReference?

  /// REEF DATA STRUCTS
  var userData = UserData()
  var sensorData = SensorData()
  var growTracker = GrowTracker()
  var currentGrowData = CurrentGrowData()
  var ecosystemData = EcosystemData()
  var reefSettings = ReefSettings()
  
  // Strain library data
  var strainNames = [String]()
  var strainDict = [String: String]()

  // Initialize() will retrieve all data from storage when app returns from terminated state
  func initialize() {

    if let firebaseID = userUID {
      databaseRef = Database.database().reference()
      
      let userRef = databaseRef?.child("Users").child(firebaseID)
      userDataRef = userRef?.child("UserData")
      sensorDataRef = userRef?.child("Reef").child("Data")
      growTrackerRef = userRef?.child("GrowTracker")
      ecosystemRef = userRef?.child("Ecosystem")
      reefSettingsRef = userRef?.child("Reef").child("Settings")
      allGrowsRef = userRef?.child("GrowTracker").child("AllGrows")
      reefScriptsRef = userRef?.child("Reef").child("Scripts")
    }
    
    readGrowTrackerData(completion: {
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "readGrowTrackerData"), object: nil)
    })
    
    observeReefSettings(completion: {
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatedSettingsData"), object: nil)
    })
    
    
    updateTimezone()
    loadStrainData()
  }
  
  func loadStrainData() {
    
    // Test load CSV Data
    let path = Bundle.main.path(forResource: "strains", ofType: "csv")!
    let importer = CSVImporter<[String]>(path: path)
    importer.startImportingRecords { $0 }.onFinish { importedRecords in
        for record in importedRecords {
          
          if record[0] == "id" {
          } else {
            // record is of type [String] and contains all data in a line
            self.strainNames.append(record[3])
            self.strainDict[record[3]] = record[7]
          }
        }
    }
  }
  
}
