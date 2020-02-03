//
//  BrowserViewController+Tabs.swift
//  SBrowser
//
//  Created by JinXu on 22/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import Foundation

extension BrowserViewController: UICollectionViewDataSource, UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate,
UICollectionViewDropDelegate, TabCellSBrowserDelegate {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return collectionViewTabs?.isHidden ?? true ? .default : .lightContent
    }

    @objc func showOverview() {
        unfocusSearchField()

        self.collectionViewTabs.reloadData()

        view.backgroundColor = .darkGray

        UIView.animate(withDuration: 0.5, animations: {
            self.view.setNeedsLayout()
        }) { _ in
            self.setNeedsStatusBarAppearanceUpdate()
        }

        view.transition({
            self.viewHeader.isHidden = true
            self.searchBar.isHidden = true
            self.progressView.isHidden = true
            self.container.isHidden = true
            self.collectionViewTabs.isHidden = false
            self.mainTools?.isHidden = true
            self.tabsTools.isHidden = false
            self.updateUIOnTabSelection(isEnable: true)
        })
    }

    @objc func newTabFromOverview() {
        addNewTabSBrowser(transition: .notAnimated) { _ in
            self.hideOverview() { _ in
                self.searchBar.becomeFirstResponder()
            }
        }
    }

    @objc func hideOverview() {
        hideOverview(completion: nil)
    }


    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewTabs.isHidden ? 0 : tabs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabCellSBrowser.reuseIdentifier, for: indexPath)

        if let cell = cell as? TabCellSBrowser {
            let tab = tabs[indexPath.row]

            cell.title.text = tab.title

            tab.add(to: cell.container)
            tab.isHidden = false
            tab.isUserInteractionEnabled = false

            cell.delegate = self
        }

        return cell
    }


    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TabCellSBrowser {
            currentTab = tabs.first { $0 == cell.container.subviews.first }
            hideOverview(completion: nil)
        }
    }

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let size = UIScreen.main.bounds.size

        // Could be 0 or less, so secure against becoming negative with minimum width of smallest iOS device.
        let width = (min(max(320, size.width), max(320, size.height)) - 8 * 2 /* left and right inset */) / 2 - 8 /* spacing */
        
        return CGSize(width: width, height: width / 4 * 3)
    }


    // MARK: UICollectionViewDragDelegate

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning
        session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {

        let tab = tabs[indexPath.row]

        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: tab.url.absoluteString as NSString))
        dragItem.localObject = tab

        return [dragItem]
    }


    // MARK: UICollectionViewDropDelegate

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate
        session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?)
        -> UICollectionViewDropProposal {

            if collectionViewTabs.hasActiveDrag {
                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }

            return UICollectionViewDropProposal(operation: .forbidden)
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        if coordinator.proposal.operation == .move,
            let item = coordinator.items.first,
            let source = item.sourceIndexPath,
            let destination = coordinator.destinationIndexPath {

            collectionView.performBatchUpdates({
                let tab = tabs.remove(at: source.row)
                tabs.insert(tab, at: destination.row)
                currentTab = tab

                collectionView.deleteItems(at: [source])
                collectionView.insertItems(at: [destination])
            })

            coordinator.drop(item.dragItem, toItemAt: destination)
        }
    }


    // MARK: TabCellDelegate

    func close(_ sender: TabCellSBrowser) {
        collectionViewTabs.performBatchUpdates({
            if let indexPath = collectionViewTabs.indexPath(for: sender) {
                collectionViewTabs.deleteItems(at: [indexPath])

                removeTabSBrowser(tabs[indexPath.row])
            }
        })
    }


    // MARK: Private Methods

    private func hideOverview(completion: ((_ finished: Bool) -> Void)?) {

        // UIViews can only ever have one superview. Move back from tabsCollection to container now.
        for tab in tabs {
            tab.isHidden = tab != currentTab
            tab.isUserInteractionEnabled = true
            tab.add(to: container)
        }

        updateChrome()

        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        }
        else {
            self.view.backgroundColor = .white
        }

        UIView.animate(withDuration: 0.5, animations: {
            self.view.setNeedsLayout()
        }) { _ in
            self.setNeedsStatusBarAppearanceUpdate()
        }

        view.transition({
            self.viewHeader.isHidden = false
            self.searchBar.isHidden = false
            self.collectionViewTabs.isHidden = true
            self.container.isHidden = false
            self.tabsTools.isHidden = true
            self.mainTools?.isHidden = false
            self.updateUIOnTabSelection(isEnable: false)
        }, completion)
    }
}
