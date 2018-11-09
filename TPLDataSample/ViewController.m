//
//  ViewController.m
//  TPLDataSample
//
//  Created by Sajad on 5/26/17.
//  Copyright © 2017 TPLHolding. All rights reserved.
//

#define KARACHI_LAT 24.946218
#define KARACHI_LNG 67.005615

#import "ViewController.h"
#import "FilesView.h"

@interface ViewController () <TGMapViewDelegate, FilesViewDelegate>
@property (weak, nonatomic) IBOutlet FilesView *filesView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.filesView.delegate = self;
    [self.filesView loadData];
    self.mapViewMode = eMapViewNormalMode;
    self.mapViewDelegate = self;
    self.enablePOISource = true;
    [self loadSceneFileAsync:@"scene.yaml"];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TGMapViewController Delegate
- (void)mapView:(TGMapViewController *)mapView didLoadSceneAsync:(NSString *)scene {
    
    TGGeoPoint geoPoint = TGGeoPointMake(KARACHI_LNG, KARACHI_LAT);
    [self animateToPosition:geoPoint withDuration:0.5f];
    [self animateToZoomLevel:10.0f withDuration:0.5f];
    
    //[self fetchAndDrawGPSDataOnMap];
}

- (void)fetchAndDrawGPSDataOnMap {
    NSBundle *assetBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"assets" withExtension:@"bundle"]];
    NSString *resourcePath = [assetBundle resourcePath];
    NSString *folderPath = [resourcePath stringByAppendingPathComponent:@"Lhr 2"];
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error];
    
    for (NSString *fileName in contents) {
        NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
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
        
        [self drawRouteWithSteps:completeGeometry isSelected:true shouldFocus:NO routeID:0]; 
        //NSLog(@"%@", [dataString description]);
    }
}


- (NSString *)stringValueFromColonSeparatedKeyValue:(NSString *)string {
    NSArray *arr = [string componentsSeparatedByString:@":"];
    NSString *value = arr[1];
    return value;
}


#pragma mark - Actions

- (IBAction)filesPressed:(UIButton *)sender {
    self.filesView.hidden = false;
}

- (IBAction)clearPressed:(id)sender {
    //[self clearRoutes];
    [self removeAllDebugMarkers];
}

- (void)drawGeometry:(NSArray *)geometery{
    //[self drawRouteWithSteps:geometery isSelected:true shouldFocus:YES routeID:0];
    
    for (int i = 0; i < geometery.count; i++) {
        NSArray *arr = geometery[i];
        TGGeoPoint geoPoint = TGGeoPointMake([arr[0] doubleValue], [arr[1] doubleValue]);
        [self addDebugPointOnPosition:geoPoint];
        
    }
}

#pragma mark - FV Delegate
- (void)filesViewDidPressHide:(FilesView *)filesView {
    self.filesView.hidden = true;
}

- (void)filesView:(FilesView *)filesView didSelectToDrawGeometer:(NSArray *)geometery {
    [self animateToFocusOnGeometry:geometery withDuration:1.0]; 
    [self drawGeometry:geometery];
    self.filesView.hidden = true;
}

- (void)filesView:(FilesView *)filesView didSelectToDrawFolderGeometeries:(NSArray *)geometeries {
    
    [UIApplication sharedApplication].idleTimerDisabled = true;
    self.filesView.hidden = true;
    for (NSArray *geometry in geometeries) {
        [self drawGeometry:geometry];
    }
    [UIApplication sharedApplication].idleTimerDisabled = false;
}


@end
