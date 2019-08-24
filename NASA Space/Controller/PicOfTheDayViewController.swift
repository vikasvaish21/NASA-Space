//
//  PicOfTheDayViewController.swift
//  NASA Space
//
//  Created by vikas on 22/08/19.
//  Copyright © 2019 project1. All rights reserved.
//

import UIKit

import DeckTransition
import SDWebImage
import CoreData
import MessageUI
class PicOfTheDayViewController:UIViewController,MFMailComposeViewControllerDelegate{
    var sharedStack:CoreDataStackManager{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.dataStack
    }
    var sharedContext: NSManagedObjectContext{
        return sharedStack.context
    }
    var emailRecipients = ["Vikasvash8@gmail.com,vikasvaish08@icloud.com"]
    
    var imageSubmissionDescription = "Attach the image or include the image URL. Please tell us about the image and indicate if you would also like it to appear in the APOD discussion forum Asterisk. Please note that by submitting your image to APOD, you are consenting for your image to be used on APOD in all of its forms unless you explicitly state otherwise. These include mirror sites, foreign language mirror sites, new media mirror sites, NASA's Open API for APOD, yearly calendars, and APOD on social fan pages as listed on the About APOD page. Some of these, like Facebook, carry advertising. We do recommend that you include a small copyright notice in a corner of your submitted images. Thanks! Ethics statement: APOD accepts composited or digitally manipulated images, but requires them to be identified as such and to have the techniques used described in a straightforward, honest and complete way."
    
    var pictures = [Picture]()
    var collectionView: UICollectionView?
    var activityIndicator:UIActivityIndicatorView?
    var startDateLoaded: Date?
    var endDateLoaded: Date?
    var refreshControl = UIRefreshControl()
    
    var insertedIndexPaths: [IndexPath]!
    var deleteIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    lazy var fetchedResultController: NSFetchedResultsController<Picture> = {
        let fetchedRequest = NSFetchRequest<Picture>(entityName: Picture.entityName())
        let sortDescriptor = NSSortDescriptor(key: "dateString", ascending: false)
        fetchedRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController<Picture>(fetchRequest: fetchedRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
        return fetchedResultsController
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startDateLoaded = UserDefaults.standard.object(forKey: "startDate") as? Date
        self.endDateLoaded = UserDefaults.standard.object(forKey: "fromDate") as? Date
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "APOD Submission",style: .plain, target: self, action: #selector(openSubmissionEmail(_:)))
        self.view.backgroundColor = UIColor.white
        self.collectionView?.backgroundColor = UIColor.white
        self.navigationController?.view.backgroundColor = UIColor.white
        let flowLayout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        let cellNib = UINib(nibName: "PicOfTheDayCell", bundle: nil)
        self.collectionView?.register(cellNib, forCellWithReuseIdentifier: PicOfTheDayCell.reuseIdentifier)
        self.collectionView?.register(UICollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "loaderView")
        
        self.view.addSubview(self.collectionView!)
        
        self.collectionView?.alwaysBounceVertical = true
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            collectionView?.refreshControl = refreshControl
        } else {
            collectionView?.addSubview(refreshControl)
        }
        performFetch()
        
        
        self.pictures = fetchedResultController.fetchedObjects!
        
        if (self.pictures.count == 0) {
            self.activityIndicator = UIActivityIndicatorView(style: .white)
            self.activityIndicator?.frame = self.view.bounds
            self.view.addSubview(self.activityIndicator!)
            self.activityIndicator?.startAnimating()
        }
        
        if pictures.isEmpty {
            getNextPhotos(fromDate: Date())
        }
    }
    
    private func performFetch() {
        do {
            try fetchedResultController.performFetch()
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        // Fetch Weather Data
        getNextPhotos(fromDate: Date())
    }
    
    @objc private func openSubmissionEmail(_ sender: Any) {
        
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients(emailRecipients)
        composeVC.setSubject("APOD Submission")
        composeVC.setMessageBody(imageSubmissionDescription, isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func getNextPage() {
        if self.startDateLoaded != nil {
            getNextPhotos(fromDate: self.startDateLoaded!)
        }
    }
    
    func  performUIUpdatesOnMain(updates: @escaping () -> Void)
    {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    func getNextPhotos(fromDate: Date) {
        var timeInterval = DateComponents()
        timeInterval.day = -27
        let startDate = Calendar.current.date(byAdding: timeInterval, to: fromDate)!
        NasaApi.sharedInstance().getPhotos(startDate: startDate, endDate: fromDate) { (success, error) in
            if(!success && error != nil) {
                self.performUIUpdatesOnMain {
                    self.activityIndicator?.stopAnimating()
                    
                    let alertController = UIAlertController(title: "Error", message: "App failed to get photos, try checking your internet connection.", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "Close Alert", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                self.performUIUpdatesOnMain {
                    self.performFetch()
                    if(self.pictures.count == 0) {
                        self.activityIndicator?.stopAnimating()
                    }
                    self.collectionView?.reloadData()
                    self.refreshControl.endRefreshing()
                }
                self.pictures = self.fetchedResultController.fetchedObjects!
                UserDefaults.standard.set(startDate, forKey: "startDate")
                
                self.startDateLoaded = startDate
                self.endDateLoaded = fromDate
            }
            
            
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension PicOfTheDayViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.collectionView != nil {
            let currentOffset = self.collectionView!.contentOffset.y;
            let maximumOffset = self.collectionView!.contentSize.height - scrollView.frame.size.height;
            
            if (maximumOffset - currentOffset <= 900) {
                getNextPage()
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let sections = fetchedResultController.sections {
            return sections.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let picture = self.pictures[indexPath.row]
        let detailViewController = PictureOfTheDayDetailViewController(picture: picture)
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchedResultController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    func pictureForIndexPath(_ indexPath : IndexPath) -> Picture? {
        if (!pictures.isEmpty) {
            return pictures[indexPath.row]
        } else {
            return Picture()
        }
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PicOfTheDayCell
        
        let picture = fetchedResultController.object(at: indexPath)
        if picture.title != nil {
            cell.title?.text = picture.title
        }
        if picture.urlString != nil {
            let url = URL(string: picture.urlString!)!
            if(picture.mediaType == "image") {
                
               // cell.picOfTheDay?.sd_addActivityIndicator()
                cell.picOfTheDay?.sd_imageTransition = .fade
                cell.picOfTheDay.sd_setImage(with: url, completed: { (image, error, cacheType, imageURL) in
             //       cell.picOfTheDay?.sd_removeActivityIndicator()
                    cell.picOfTheDay.image = image
                })
                cell.picOfTheDay?.sd_setImage(with:url)
                //                cell.pictureOfTheDay?.kf.setImage(with: url)
                cell.picOfTheDay.contentMode = .scaleAspectFill
            }
            if(picture.mediaType == "video") {
                
            }
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "loaderView", for: indexPath) as! UICollectionViewCell
        let loader = UIActivityIndicatorView(style: .gray)
        loader.center = view.contentView.center
        view.backgroundColor = .white
        view.addSubview(loader)
        loader.startAnimating()
        return view
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
        //        / CGFloat(1)
        let size = Int((collectionView.bounds.width - totalSpace))
        if(self.pictures.count > 0) {
            return CGSize(width: size, height: 60)
        } else {
            return CGSize.zero
        }
    }
}

extension PicOfTheDayViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
        //        / CGFloat(1)
        let size = Int((collectionView.bounds.width - totalSpace))
        return CGSize(width: size, height: size)
    }
}

extension PicOfTheDayViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deleteIndexPaths  = [IndexPath]()
        updatedIndexPaths  = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
        case .update:
            updatedIndexPaths.append(indexPath!)
        case .delete:
            deleteIndexPaths.append(indexPath!)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            for indexPath in self.insertedIndexPaths {
                self.collectionView?.insertItems(at: [indexPath])
            }
            for indexPath in self.deleteIndexPaths {
                self.collectionView?.deleteItems(at: [indexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView?.reloadItems(at: [indexPath])
            }
        }, completion: nil)
    }
}
