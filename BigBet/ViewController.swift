//
//  ViewController.swift
//  BigBet
//
//  Created by Egemen Ayhan on 9.05.2025.
//

import UIKit

class ViewController: UIViewController {

    let eventsUseCase = EventsUseCase(networkManager: NetworkManager(baseURL: "https://api.the-odds-api.com", adapter: AlamofireNetworkAdapter()))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Task {
            do {
                let events = try await self.eventsUseCase.fetchEvents()
                print(events)
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

