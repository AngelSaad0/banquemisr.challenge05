//
//  TestingUtilities.swift
//  banquemisr.challenge05Tests
//
//  Created by Engy on 06/10/2024.
//

import XCTest
@testable import banquemisr_challenge05
import CoreData

class ConnectivityManagerDisconnectedMock: ConnectivityManagerProtocol {
    func checkInternetConnection(completion: @escaping (Bool) -> Void) {
        completion(false)
    }
}

func clearCoreData(for entityName: String, context: NSManagedObjectContext) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    do {
        try context.execute(batchDeleteRequest)
        try context.save()
        print("\(entityName) cleared successfully.")
    } catch {
        print("Failed to clear \(entityName): \(error)")
    }
}
