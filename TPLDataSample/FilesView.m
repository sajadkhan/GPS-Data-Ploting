//
//  FilesView.m
//  TPLDataSample
//
//  Created by Sajad on 5/26/17.
//  Copyright © 2017 TPLHolding. All rights reserved.
//

#import "FilesView.h"

@interface FilesView() <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *filesListTable;
@property (weak, nonatomic) IBOutlet UITableView *folderListView;

@property (nonatomic, strong) NSArray *folders;
@property (nonatomic, strong) NSArray *filesInSelectedFolder;

@property (nonatomic, strong) NSString *folderDirectory;
@property (nonatomic, strong) NSString *selectedFolder;



@end

@implementation FilesView

- (void)loadData {
    NSBundle *assetBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"assets" withExtension:@"bundle"]];
    NSString *resourcePath = [assetBundle resourcePath];
    NSString *folderPath = [resourcePath stringByAppendingPathComponent:@"Data"];
    self.folderDirectory = folderPath;
    NSError *error;
    NSArray *folders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error];
    self.folders = [[NSArray alloc] initWithArray:folders];
    self.selectedFolder = folders[0];
    [self updateSelectedFolderFiles];
}

- (void)updateSelectedFolderFiles{
    NSString *folderPath = [self.folderDirectory stringByAppendingPathComponent:self.selectedFolder];
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error];
    self.filesInSelectedFolder = [[NSArray alloc] initWithArray:files];
}


#pragma mark - TV DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.folderListView]) {
        return self.folders.count;
    }
    else {
        return [self.filesInSelectedFolder count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    
    if ([tableView isEqual:self.folderListView]) {
        cell.textLabel.text = [self.folders objectAtIndex:indexPath.row];
    }
    else {
        cell.textLabel.text = [self.filesInSelectedFolder objectAtIndex:indexPath.row];
    }
    
    return cell;
}

#pragma mark - TV Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.folderListView]) {
        self.selectedFolder = [self.folders objectAtIndex:indexPath.row];
        [self updateSelectedFolderFiles]; 
        [self.filesListTable reloadData];
    }
    else {
        [self createGeometeryForFile:self.filesInSelectedFolder[indexPath.row]];
    }
}

- (void)createGeometeryForFile:(NSString *)fileName {
    NSString *folderPath = [self.folderDirectory stringByAppendingPathComponent:self.selectedFolder];
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    NSArray *completeGeometry = [self geometerForFilePath:filePath];
    [self.delegate filesView:self didSelectToDrawGeometer:completeGeometry]; 

}

- (NSArray *)geometerForFilePath:(NSString *)filePath{
    
    NSString *dataString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [dataString componentsSeparatedByString:@"\n"];
    
    NSMutableArray *completeGeometry = [[NSMutableArray alloc] init];
    
    for (NSString *line in lines) {
        NSArray *components = [[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@","];
        double lat = 0.0, lng = 0.0, acc = 0.0;
        for (NSString *component in components) {
            NSString *comp = [component stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([comp containsString:@"lat"])
                lat = [[self stringValueFromColonSeparatedKeyValue:comp] doubleValue];
            if ([comp containsString:@"lng"])
                lng = [[self stringValueFromColonSeparatedKeyValue:comp] doubleValue];
            if ([comp containsString:@"accuracy"])
                acc = [[self stringValueFromColonSeparatedKeyValue:comp] doubleValue];
            //NSLog(@"%f", acc);
        }
        NSArray *latlng = [NSArray arrayWithObjects:[NSNumber numberWithDouble:lng], [NSNumber numberWithDouble:lat], nil];
        [completeGeometry addObject:latlng];
        
    }

    return completeGeometry;
}

- (IBAction)drawFolderPressed:(id)sender {
    NSString *folderPath = [self.folderDirectory stringByAppendingPathComponent:self.selectedFolder];
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error];
    NSMutableArray *allGeometries = [[NSMutableArray alloc] init];
    
    for (NSString *fileName in contents) {
        NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
        NSArray *completeGeometry = [self geometerForFilePath:filePath];
        [allGeometries addObject:completeGeometry];
    }
    
    [self.delegate filesView:self didSelectToDrawFolderGeometeries:allGeometries]; 
}

- (NSString *)stringValueFromColonSeparatedKeyValue:(NSString *)string {
    NSArray *arr = [string componentsSeparatedByString:@":"];
    NSString *value = arr[1];
    return value;
}



- (IBAction)hidePressed:(id)sender {
    [self.delegate filesViewDidPressHide:self];
}

@end
