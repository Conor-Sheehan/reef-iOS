//
//  HomeVC.swift
//  reef
//
//  Created by Conor Sheehan on 8/28/20.
//  Copyright © 2020 Infinitry. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
  
  fileprivate var growTrackerData: [ProgressData] = []
  private weak var appDelegate: AppDelegate!
  @IBOutlet weak var collectionView: UICollectionView!
  
  private var homeSegues = R.segue.homeVC.self
  
  override func viewDidLoad() {
    super.viewDidLoad()

   if let appDeleg = UIApplication.shared.delegate as? AppDelegate {
      appDelegate = appDeleg
    }
    
    //navigationController?.navigationBar.isHidden = true
    collectionView.backgroundColor = .clear
    collectionView.delegate = self
    collectionView.dataSource = self
    
    loadGrowTrackerData()
    NotificationCenter.default.addObserver(self, selector: #selector(self.loadGrowTrackerData),
                                           name: NSNotification.Name(rawValue: "readGrowTrackerData"), object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    loadGrowTrackerData()
  }
  
  @objc func loadGrowTrackerData() {
    growTrackerData = appDelegate.appBrain.getGrowTrackerData()
    self.collectionView.reloadData()
  }
  
  func handleCellSelect(index: Int) {
    switch index {
    case 0:
      segue(to: homeSegues.ecosystemVC.identifier)
    case 1:
      segue(to: homeSegues.germinationVC.identifier)
    case 2:
      segue(to: homeSegues.seedlingVC.identifier)
    case 3:
      segue(to: homeSegues.vegetativeVC.identifier)
    case 4:
      segue(to: homeSegues.floweringVC.identifier)
    default:
      print("Do nothing")
    }
    
  }
  
  func segue(to viewcontroller: String) {
    self.performSegue(withIdentifier: viewcontroller, sender: self)
  }

}

// Handle Sensor Data Collection View
extension HomeVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
      return CGSize(width: collectionView.frame.width/1.5, height: collectionView.frame.height)
    }
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return growTrackerData.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
        "ProgressCell", for: indexPath) as? ProgressCell
      cell?.setNeedsLayout()
      cell?.layoutIfNeeded()
      cell?.data = self.growTrackerData[indexPath.item]
      return cell!
    }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print("Selected cell with index:", indexPath.item)
    handleCellSelect(index: indexPath.item)
  }
  
  func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
      let cell = collectionView.cellForItem(at: indexPath)
      cell?.alpha = 0.5
  }

  func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
      let cell = collectionView.cellForItem(at: indexPath)
      cell?.alpha = 1.0
  }
}
