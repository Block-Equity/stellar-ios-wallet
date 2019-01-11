//
//  UICollectionView+Extensions.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-28.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

extension UICollectionView {
    /**
     Shorthand method to returns a reusable header for the class inferred by the return-type

     - parameter indexPath:   The index path specifying the location of the cell.
     - parameter viewType: The view class to dequeue

     - returns: A `Reusable`, `UICollectionReusableView` instance

     - note: The `viewType` parameter can generally be omitted and infered by the return type,
     except when your type is in a variable and cannot be determined at compile time.
     - seealso: `dequeueReusableSupplementaryView(ofKind:,withReuseIdentifier:,for:)`
     */
    final func dequeueHeader<T: UICollectionReusableView> (for indexPath: IndexPath,
                                                           viewType: T.Type = T.self) -> T where T: Reusable {
        return self.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                     for: indexPath,
                                                     viewType: viewType)
    }

    /**
     Shorthand method to returns a reusable footer for the class inferred by the return-type

     - parameter indexPath:   The index path specifying the location of the cell.
     - parameter viewType: The view class to dequeue

     - returns: A `Reusable`, `UICollectionReusableView` instance

     - note: The `viewType` parameter can generally be omitted and infered by the return type,
     except when your type is in a variable and cannot be determined at compile time.
     - seealso: `dequeueReusableSupplementaryView(ofKind:,withReuseIdentifier:,for:)`
     */
    final func dequeueFooter<T: UICollectionReusableView> (for indexPath: IndexPath,
                                                           viewType: T.Type = T.self) -> T where T: Reusable {
        return self.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                     for: indexPath,
                                                     viewType: viewType)
    }

    final func registerHeader<T: UICollectionReusableView>(_ supplementaryViewType: T.Type)
        where T: Reusable & NibLoadable {
        self.register(supplementaryViewType: supplementaryViewType,
                      ofKind: UICollectionView.elementKindSectionHeader)
    }

    final func registerHeader<T: UICollectionReusableView>(_ supplementaryViewType: T.Type)
        where T: Reusable & NibOwnerLoadable {
            self.register(supplementaryViewType: supplementaryViewType,
                          ofKind: UICollectionView.elementKindSectionHeader)
    }

    final func registerFooter<T: UICollectionReusableView>(_ supplementaryViewType: T.Type)
        where T: Reusable & NibLoadable {
            self.register(supplementaryViewType: supplementaryViewType,
                          ofKind: UICollectionView.elementKindSectionFooter)
    }
}
