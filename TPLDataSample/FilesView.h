//
//  FilesView.h
//  TPLDataSample
//
//  Created by Sajad on 5/26/17.
//  Copyright © 2017 TPLHolding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilesView;

@protocol FilesViewDelegate <NSObject>

- (void)filesView:(FilesView *)filesView didSelectToDrawGeometer:(NSArray *)geometery;
- (void)filesView:(FilesView *)filesView didSelectToDrawFolderGeometeries:(NSArray *)geometeries;

- (void)filesViewDidPressHide:(FilesView *)filesView;

@end

@interface FilesView : UIView

@property (nonatomic, assign) id<FilesViewDelegate> delegate; 

- (void)loadData;
@end
