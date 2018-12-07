//
//  ViewController.swift
//  DragAndDropCollectionToView
//
//  Created by Hemant on 12/7/18.
//  Copyright © 2018 Hemant. All rights reserved.
//

import UIKit

///
class ViewController: UIViewController {
    
    //MARK: Private Properties
    //Data Source for CollectionView
    private var items = ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "5.jpg", "1.jpg", "2.jpg", "3.jpg", "4.jpg", "5.jpg"]
    ///
    private var dropedImagesArray: [UIImageView] = []
    
    ///
    //MARK: Outlets
    ///
    @IBOutlet weak var collectionView: UICollectionView!
    ///
    @IBOutlet weak var dropAreaView: UIView!
    
    //MARK: Variables
    ///
    var panGesture = UIPanGestureRecognizer()
    
    //MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
       //CollectionView drag and drop configuration
        self.collectionView.dragInteractionEnabled = true
        self.collectionView.dragDelegate = self        //self.collectionView.dropDelegate = self
        
        // Add DropInteraction to dropAreaView
        dropAreaView.addInteraction(UIDropInteraction(delegate: self))
        
    }
    
    //MARK: Private Methods
    
    /// This method moves a cell from source indexPath to destination indexPath within the same collection view. It works for only 1 item. If multiple items selected, no reordering happens.
    ///
    /// - Parameters:
    ///   - coordinator: coordinator obtained from performDropWith: UICollectionViewDropDelegate method
    ///   - destinationIndexPath: indexpath of the collection view where the user drops the element
    ///   - collectionView: collectionView in which reordering needs to be done.
    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        let items = coordinator.items
        if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath {
            var dIndexPath = destinationIndexPath
            if dIndexPath.row >= collectionView.numberOfItems(inSection: 0) {
                dIndexPath.row = collectionView.numberOfItems(inSection: 0) - 1
            }
            
            collectionView.performBatchUpdates({
                
                self.items.remove(at: sourceIndexPath.row)
                self.items.insert(item.dragItem.localObject as! String, at: dIndexPath.row)
                
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [dIndexPath])
            })
            coordinator.drop(items.first!.dragItem, toItemAt: dIndexPath)
        }
    }
    
    /// This method copies a cell from source indexPath in 1st collection view to destination indexPath in 2nd collection view. It works for multiple items.
    ///
    /// - Parameters:
    ///   - coordinator: coordinator obtained from performDropWith: UICollectionViewDropDelegate method
    ///   - destinationIndexPath: indexpath of the collection view where the user drops the element
    ///   - collectionView: collectionView in which reordering needs to be done.
    private func copyItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        collectionView.performBatchUpdates({
            var indexPaths = [IndexPath]()
            for (index, item) in coordinator.items.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                
                self.items.insert(item.dragItem.localObject as! String, at: indexPath.row)
                
                indexPaths.append(indexPath)
            }
            collectionView.insertItems(at: indexPaths)
        })
    }
    
    // The Pan Gesture
    func createPanGestureRecognizer() {
        dropedImagesArray.forEach {
            panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(handlePanGesture(panGesture:)))
            //UIPanGestureRecognizer(target: self, action:(#sele(("handlePanGesture:"))))
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(panGesture)
        }
        
    }
    
    @objc func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        // get translation
        let translation = panGesture.translation(in: view)
        panGesture.setTranslation(CGPoint.zero, in: view)
        print(translation)
        
        // create a new Label and give it the parameters of the old one
        let imageView = panGesture.view as! UIImageView
        imageView.center = CGPoint(x: imageView.center.x+translation.x, y: imageView.center.y+translation.y)
        //imageView.isMultipleTouchEnabled = true
        imageView.isUserInteractionEnabled = true
    }
}

// MARK: - UICollectionViewDataSource Methods
extension ViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath) as! DragDropCollectionViewCell
        cell.customImageView?.image = UIImage(named: self.items[indexPath.row])
        cell.customLabel.text = self.items[indexPath.row].capitalized
        return cell
    }
}

// MARK: - UICollectionViewDragDelegate Methods
extension ViewController : UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        // 1
        let item = self.items[indexPath.row]
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let item = self.items[indexPath.row]
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        // 2
        let previewParameters = UIDragPreviewParameters()
        previewParameters.visiblePath = UIBezierPath(rect: CGRect(x: 25, y: 25, width: 120, height: 120))
        return previewParameters
    }
}

// MARK: - UICollectionViewDropDelegate Methods
/*extension ViewController : UICollectionViewDropDelegate
 {
 func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool
 {
 return session.canLoadObjects(ofClass: NSString.self)
 }
 
 func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
 {
 if collectionView.hasActiveDrag
 {
 return UICollectionViewDropProposal(operation: .move, intent: .unspecified)
 }
 else
 {
 return UICollectionViewDropProposal(operation: .forbidden)
 }
 }
 
 func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
 {
 let destinationIndexPath: IndexPath
 if let indexPath = coordinator.destinationIndexPath
 {
 destinationIndexPath = indexPath
 }
 else
 {
 // Get last index path of table view.
 let section = collectionView.numberOfSections - 1
 let row = collectionView.numberOfItems(inSection: section)
 destinationIndexPath = IndexPath(row: row, section: section)
 }
 
 switch coordinator.proposal.operation
 {
 case .move:
 self.reorderItems(coordinator: coordinator, destinationIndexPath:destinationIndexPath, collectionView: collectionView)
 break
 
 case .copy:
 self.copyItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
 
 default:
 return
 }
 }
 }*/

extension ViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        for dragItem in session.items {
            dragItem.itemProvider.loadObject(ofClass: NSString.self, completionHandler: { (obj, err) in
                
                if let err = err {
                    print("Failed to load our dragged item:", err)
                    return
                }
                
                guard let draggedImageName = obj as? String else { return }
                
                DispatchQueue.main.async {
                    let imageView = UIImageView(image: UIImage(named: draggedImageName))
                    self.dropAreaView?.addSubview(imageView)
                    imageView.frame = CGRect(x: 0, y: 0, width: 170, height: 170)
                    
                    let centerPoint = session.location(in: self.dropAreaView)
                    imageView.center = centerPoint
                    self.dropedImagesArray.append(imageView)
                    self.createPanGestureRecognizer()
                }
            })
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
}

