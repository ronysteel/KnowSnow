//
//  FirstViewController.swift
//  KnowSnow
//
//  Created by Jack Sharkey on 2/17/17.
//  Copyright © 2017 Jack Sharkey. All rights reserved.
//

import UIKit
import SideMenu
import PopupDialog
import SwiftSpinner

class FirstViewController: UIViewController, UIScrollViewDelegate, DataReturnedDelegate {

    
    
    //array of towns

    var towns = ["weston", "norwalk", "redding", "westport", "shelton", "danbury", "sherman", "newCanaan", "ridgefield", "newFairfield", "bridgeport", "trumbull", "newtown", "darien", "bethel", "fairfield", "stamford", "brookfield", "easton", "monroe", "greenwich", "wilton"]
    
    
    @IBOutlet weak var mapScrollView: UIScrollView!
    @IBOutlet weak var mapView: UIView!
    private let dataModel = RetrieveMapInfo()

    
    @IBOutlet weak var ridgefield: UILabel!
    @IBOutlet weak var bethel: UILabel!
    @IBOutlet weak var danbury: UILabel!
    @IBOutlet weak var norwalk: UILabel!
    @IBOutlet weak var westport: UILabel!
    @IBOutlet weak var sherman: UILabel!
    @IBOutlet weak var newFairfield: UILabel!
    @IBOutlet weak var brookfield: UILabel!
    @IBOutlet weak var newtown: UILabel!
    @IBOutlet weak var redding: UILabel!
    @IBOutlet weak var monroe: UILabel!
    @IBOutlet weak var shelton: UILabel!
    @IBOutlet weak var trumbull: UILabel!
    @IBOutlet weak var easton: UILabel!
    @IBOutlet weak var weston: UILabel!
    @IBOutlet weak var wilton: UILabel!
    @IBOutlet weak var greenwich: UILabel!
    @IBOutlet weak var stamford: UILabel!
    @IBOutlet weak var bridgeport: UILabel!
    @IBOutlet weak var newCanaan: UILabel!
    @IBOutlet weak var fairfield: UILabel!
    @IBOutlet weak var darien: UILabel!
    @IBOutlet weak var stratford: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    
    //init

    override func viewDidLoad() {
        super.viewDidLoad()
        mapScrollView.delegate = self
        
        mapScrollView.clipsToBounds = true
        
        let darkGrey = UIColor(red:0.27, green:0.33, blue:0.36, alpha:1.0)
        dataModel.delegate = self

        
        //let scale = CGFloat(self.mapScrollView.frame.size.width/self.mapView.frame.size.width)
        //self.mapScrollView.setZoomScale(scale, animated: true)
        
        self.navigationController?.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = darkGrey
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir Light", size: 22)!, NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(SecondViewController.infoPressed), for: .touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.leftBarButtonItem = infoBarButtonItem
        self.navigationItem.title = "Map"

        
        //TODO: MOVE THIS TO GET DONE BEFORE SCREEN SHOWS

        
        let scrollViewFrame = mapScrollView.frame
        let scaleWidth = scrollViewFrame.size.width / mapScrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / mapScrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        mapScrollView.minimumZoomScale = minScale;

        // 5
        mapScrollView.maximumZoomScale = 1.0
        mapScrollView.zoomScale = minScale;

        // 6
        centerScrollViewContents()
        
        
        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))

        
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        // Define the menus
        let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! UISideMenuNavigationController
        menuLeftNavigationController.leftSide = true
        // UISideMenuNavigationController is a subclass of UINavigationController, so do any additional configuration
        // of it here like setting its viewControllers. If you're using storyboards, you'll want to do something like:
        // let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! UISideMenuNavigationController
        SideMenuManager.menuLeftNavigationController = menuLeftNavigationController
        
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        SideMenuManager.menuPresentMode = .menuSlideIn
        SideMenuManager.menuWidth = max(round(min((FirstViewController.appScreenRect.width), (FirstViewController.appScreenRect.height)) * 0.88), 240)
        var j = 0
        
        //init percentages set
        for _ in allTownObjects {
            changeMap(percentage: allTownObjects[j].closing, town: allTownObjects[j].name)
            j = j + 1
        }
        
        let f = DateFormatter()
        f.dateFormat = "M/dd/yyyy"
     
        dateLabel.text = "For: " + dateString

        
    }

    override func viewWillLayoutSubviews(){
        setZoomScale()
        
    }
    var selectedDate = Date()
    let f = DateFormatter();
    

    @IBAction func calenderPressed(_ sender: Any) {
        let minDate = Date()
        DatePickerDialog().show(title: "Select Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: self.selectedDate, minimumDate: minDate, maximumDate: nil, datePickerMode: UIDatePickerMode.date) { (date) in
            if (date != nil) {
                self.selectedDate = date!
                
                let data = date!
                self.dataModel.userDidEnterData(data:data)
                SwiftSpinner.show("Loading Percentages...")
                
                
                self.f.dateFormat = "EEEE, MMMM dd"
                dateString = self.f.string(from:date!)
                
            }
        }
    }
    
    func centerScrollViewContents() {
        let boundsSize = mapScrollView.bounds.size
        var contentsFrame = mapView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        mapView.frame = contentsFrame
    }
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        // 1
        let pointInView = recognizer.location(in: mapView)
        
        // 2
        var newZoomScale = mapScrollView.zoomScale * 1.5
        newZoomScale = min(newZoomScale, mapScrollView.maximumZoomScale)
        
        // 3
        let scrollViewSize = mapScrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRect(x: x, y: y,width: w, height: h)
        
        // 4
        mapScrollView.zoom(to: rectToZoomTo, animated: true)
    }
    func setZoomScale() {
        let minZoom = min(self.view.bounds.size.width / mapView!.bounds.size.width, self.view.bounds.size.height / mapView!.bounds.size.height);
        
//        if (minZoom > 1.0) {
//            minZoom = 1.0;
//        }
        print("set zoom scale to \(minZoom)")

        mapScrollView.minimumZoomScale = minZoom;
        mapScrollView.zoomScale = minZoom;
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mapView
    }
    
    internal static var appScreenRect: CGRect {
        let appWindowRect = UIApplication.shared.keyWindow?.bounds ?? UIWindow().bounds
        return appWindowRect
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
            case UISwipeGestureRecognizerDirection.down: break
            case UISwipeGestureRecognizerDirection.left:
                dismiss(animated: true, completion: nil)
            case UISwipeGestureRecognizerDirection.up: break
            default:
                break
            }
        }
    }
   
    
    @IBOutlet weak var tabbedButtons: UISegmentedControl!
    
    
    @IBAction func tabbedButtons(_ sender: Any) {
        var j = 0;
        if(tabbedButtons.selectedSegmentIndex == 0)
        {
            for _ in allTownObjects {
                changeMap(percentage: allTownObjects[j].closing, town: allTownObjects[j].name)
                j = j + 1
            }
        }
        else if(tabbedButtons.selectedSegmentIndex == 1)
        {
            for _ in allTownObjects {
                changeMap(percentage: allTownObjects[j].delay, town: allTownObjects[j].name)
                j = j + 1
            }
        }
        else if(tabbedButtons.selectedSegmentIndex == 2)
        {
            for _ in allTownObjects {
                changeMap(percentage: allTownObjects[j].early, town: allTownObjects[j].name)
                j = j + 1
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func changeMap(percentage: String, town: String) {
        switch town {
        case "sherman":
            if (percentage != "-") {
                sherman.text = percentage
            } else {
                sherman.text = "n/a"
            }
            if (percentage == "100%") {
                sherman.font = sherman.font.withSize(12)
            }
          
        case "newFairfield":
            if (percentage != "-") {
                newFairfield.text = percentage
            } else {
                newFairfield.text = "n/a"
            }
            if (percentage == "100%") {
                newFairfield.font = newFairfield.font.withSize(15)
            }
        case "brookfield":
            if (percentage != "-") {
                brookfield.text = percentage
            } else {
                brookfield.text = "n/a"
            }
            if (percentage == "100%") {
                brookfield.font = brookfield.font.withSize(13)
            }
        case "danbury":
            if (percentage != "-") {
                danbury.text = percentage
            } else {
                danbury.text = "n/a"
            }
            if (percentage == "100%") {
                danbury.font = danbury.font.withSize(15)
            }
        case "bethel":
            if (percentage != "-") {
                bethel.text = percentage
            } else {
                bethel.text = "n/a"
            }
            if (percentage == "100%") {
                bethel.font = bethel.font.withSize(12)
            }
        case "newtown":
            if (percentage != "-") {
                newtown.text = percentage
            } else {
                newtown.text = "n/a"
            }
            if (percentage == "100%") {
                newtown.font = newtown.font.withSize(15)
            }
        case "ridgefield":
            if (percentage != "-") {
                ridgefield.text = percentage
            } else {
                ridgefield.text = "n/a"
            }
            if (percentage == "100%") {
                ridgefield.font = ridgefield.font.withSize(15)
            }
        case "redding":
            if (percentage != "-") {
                redding.text = percentage
            } else {
                redding.text = "n/a"
            }
            if (percentage == "100%") {
                redding.font = redding.font.withSize(15)
            }
        case "monroe":
            if (percentage != "-") {
                monroe.text = percentage
            } else {
                monroe.text = "n/a"
            }
            if (percentage == "100%") {
                monroe.font = monroe.font.withSize(15)
            }
        case "shelton":
            if (percentage != "-") {
                shelton.text = percentage
            } else {
                shelton.text = "n/a"
            }
            if (percentage == "100%") {
                shelton.font = shelton.font.withSize(15)
            }
        case "trumbull":
            if (percentage != "-") {
                trumbull.text = percentage
            } else {
                trumbull.text = "n/a"
            }
            if (percentage == "100%") {
                trumbull.font = trumbull.font.withSize(15)
            }
        case "easton":
            print(percentage)
            if (percentage != "-") {
                easton.text = percentage
            } else {
                easton.text = "n/a"
            }
            if (percentage == "100%") {
                easton.font = easton.font.withSize(15)
            }
        case "weston":
            if (percentage != "-") {
                weston.text = percentage
            } else {
                weston.text = "n/a"
            }
            if (percentage == "100%") {
                weston.font = weston.font.withSize(15)
            }
        case "wilton":
            if (percentage != "-") {
                wilton.text = percentage
            } else {
                wilton.text = "n/a"
            }
            if (percentage == "100%") {
                wilton.font = wilton.font.withSize(15)
            }
        case "newCanaan":
            if (percentage != "-") {
                newCanaan.text = percentage
            } else {
                newCanaan.text = "n/a"
            }
            if (percentage == "100%") {
                newCanaan.font = newCanaan.font.withSize(15)
            }
        case "stamford":
            if (percentage != "-") {
                stamford.text = percentage
            } else {
                stamford.text = "n/a"
            }
            if (percentage == "100%") {
                stamford.font = stamford.font.withSize(15)
            }
        case "greenwich":
            if (percentage != "-") {
                greenwich.text = percentage
            } else {
                greenwich.text = "n/a"
            }
            if (percentage == "100%") {
                greenwich.font = greenwich.font.withSize(15)
            }
        case "darien":
            if (percentage != "-") {
                darien.text = percentage
            } else {
                darien.text = "n/a"
            }
            if (percentage == "100%") {
                darien.font = darien.font.withSize(12)
            }
        case "norwalk":
            if (percentage != "-") {
                norwalk.text = percentage
            } else {
                norwalk.text = "n/a"
            }
            if (percentage == "100%") {
                norwalk.font = norwalk.font.withSize(15)
            }
        case "westport":
            if (percentage != "-") {
                westport.text = percentage
            } else {
                westport.text = "n/a"
            }
            if (percentage == "100%") {
                westport.font = westport.font.withSize(15)
            }
        case "fairfield":
            if (percentage != "-") {
                fairfield.text = percentage
            } else {
                fairfield.text = "n/a"
            }
            if (percentage == "100%") {
                fairfield.font = fairfield.font.withSize(15)
            }
        case "bridgeport":
            if (percentage != "-") {
                bridgeport.text = percentage
            } else {
                bridgeport.text = "n/a"
            }
            if (percentage == "100%") {
                bridgeport.font = bridgeport.font.withSize(13)
            }
        case "stratford":
            if (percentage != "-") {
                stratford.text = percentage
            } else {
                stratford.text = "n/a"
            }
            if (percentage == "100%") {
                stratford.font = stratford.font.withSize(11)
            }
        default:
            print("error")
        }
        
        
        
    }
    
    
    func infoPressed() {
        let infoPage = self.storyboard?.instantiateViewController(withIdentifier: "infoVC") as! UINavigationController
        self.tabBarController?.present(infoPage, animated: true, completion: nil)
    }
    
    func newDataReceieved() {
        var j = 0;
        for _ in allTownObjects {
            print(allTownObjects[j])
            changeMap(percentage: allTownObjects[j].closing, town: allTownObjects[j].name)
            j = j + 1;
        }
        dateLabel.text = "For: " + dateString
        SwiftSpinner.hide()
    }
    
  
}


