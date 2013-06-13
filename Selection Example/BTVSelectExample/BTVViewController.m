//
//  BTVViewController.m
//  BTVSelectExample
//
//  Created by Indrajit Khare on 5/28/13.
//  Copyright (c) 2013 Indrajit Khare. All rights reserved.
//

#import "BTVViewController.h"
#import "BumpTableController.h"

@interface BTVViewController ()

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) BumpTableController *tableController;
@property (nonatomic, strong) NSArray *baseData;
@property (nonatomic, strong) NSMutableSet *selectedKeys;

@end

@implementation BTVViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.selectedKeys = [NSMutableSet new];
        self.baseData = @[@"Adler Typ 10 2.5 Litre (1937–1940)", @"Alfa Romeo Romeo 1 and ", @"Austin FX4 — the classi London black cab", @"Austin 7 - many two-door version", @"Autobianchi Bianchina Transformaile", @"Bentley State Limousin", @"Bugatti Atlantic (1937", @"Bugatti Type 57 (1934", @"Bugatti T57 Aerolithe(1935)", @"Buick Roadmaster 1st generaion (rear), 2nd generation (front)", @"Cadillac Eldorado Brougham – (1957)", @"Cadillac Fleetwood (1st generation Note: Zoom in on the rear door and possibly the second.", @"Chevrolet Master 2-door (1935", @"Chevrolet Master Deluxe 2-doo (1935))", @"Chrysler Imperial Parade Phaeto", @"Chrysler Royal (rear doors", @"Citroën 2CV early models (948–1964)", @"Citroën H Va", @"Citroën Tracion Avant (1934–1957)", @"Dacia Logan MC", @"Delahay", @"DeSoto ars in the 1940s (1946-48 S-11)", @"DKW 1000 S (1958–1961) (Front door", @"DKW F7 (1937–1939", @"DKW F8 (1939–1942", @"Dodge cars in the1930s & 1940s", @"EMW 340 (1949–1955) (Front doo)", @"Facel Vega Excellenc", @"Fiat 500 (approx. 196-57)", @"Fiat 500 Spyder Bertone (947)", @"Fiat 508 Balilla (1934–1939) Rear door on 4-door sedans)", @"Fiat 518 Ardita (1933–1938", @"Fiat 60", @"Fiat 110 (1960) (Front door)", @"Fiat 1200 (1955) (Front door", @"Fiat AR 55 Campagnola (1963", @"Fiat Camareno 1100 (1932", @"Fiat FS (1946", @"Fiat Topolino(1936–1955)", @"Ford Model B (1932) (193 V8)", @"Ford F-150 SuperCab (1997–prsent) (Front doors conventional with rear suicide half-doors)", @"Ford Ranger (2000–present) (Supercab version has two rear suicide doors", @"Ford Thunderbird 4-door models (1967–1971", @"Goggomobil (1955", @"Honda Element (203–present) (Has conventional front doors, with suicide half-doors in rear)", @"Hongqi CA 7", @"Hongqi CA 70/772/773", @"Hongqi CA 765", @"Hongqi HQ", @"Jaguar MK (1946) (Front door)", @"Jowett Javelin (1947–1953", @"Lancia Aprilia (1937–1948", @"Lancia Ardea (1939–1953", @"Lancia Augusta (1933–196)", @"Lancia Aurelia (1950–1958", @"Lincoln Continental 4-doo sedans (1961–1969), 4-door convertibles (1961–1967)", @"Maybach Zeppeli", @"Mazda B-Series nd Mazda BT-50 Freestyle Cab (2002–present)", @"Mazda RX-8 (2004–2011) (Has conventional front doors, withsuicide half-doors in rear)", @"Mercedes-Benz 170 (1928–1948", @"Mercedes-Benz 200t (1934", @"Mercedes-Benz 50", @"Mercedes-Benz 54 (1938)", @"Mercury 4-door sedan (149–1951)", @"MG TF (1953", @"MINI Clubma — Has conventional front doors, with one rear suicide half-door", @"Nissan Titan — Extended cab model", @"Nissan Prince Royal- rea", @"Opel Kapitän (1938–1953)(Rear door)", @"Opel/Vauxhall Meriva (2010–present)(Rear door)", @"Packard 110 Sedan (1941) (Rear door)", @"Panhard Dyn", @"Peel P5", @"Peugeot202 (1938)", @"Peugeot 203 (19481960)", @"Peugeot 301 (1935", @"Peugeot 302 (1937", @"Peugeot 402 (19381950)", @"Peugeot 402 Darlmat (150)", @"Peugeot 601 (1940", @"Pierce Silver Arrw", @"Praga Piccolo Furgn (1938)", @"Renault 4CV (1946–1961) (Font door)", @"Riley RM (1945–1955) (Front door", @"Rolls-Royce Phanto", @"Rolls-Royce Phanto Coupe", @"Rolls-Royce Phantom Dropead Coupe", @"Rolls-Royce Ghos", @"Rolls-Royce Phanom I, II, III, IV, V and VI", @"Rolls-Royce Silver Dawn (front", @"Rolls-Royce Silver Wrait", @"Rover P4 (Cars like the over 90 had conventional front doors, with suicide rear doors)", @"Rover P", @"Rover S12 (1946) (Both doors rear hinged)", @"Saab (Saab 92, Saab 93 and Saab 95/96 eary models)", @"Saturn Ion Quad Coupe (2002–2007) (Has conventiona front doors, with suicide half-doors in the rear.)", @"Saturn SC (1999–2002) (One rear suicide half-door on driver's side", @"Savage Rivale Roadyacht GTS (2009", @"Singer SM1500 (1947–1954) (Rear dor)", @"SEAT 600, SEAT 600 D (1957–1970", @"SEAT 800 (1963-1968", @"Škoda 1101/1102 (196–1952)", @"Škoda Popular (1933–1946", @"Spyker D1", @"Studebake Champion (1939–1952) (Rear door on 4-door Sedans)", @"Subaru 36", @"Sunbeam-Tlbot Ten", @"Sunbeam-Talbot 90(Rear door on four door models)", @"Syrena early model", @"Tatra T57 (1931–198)", @"Tatra T600 (1947–195) (Front door)", @"Toyota Century Roya", @"Toyota Origi", @"Toyota FJ Criser (2006–present) (Conventional front doors, suicide half-doors in rear)", @"Tucker Torpedo (1948) (Rear door", @"Vespa 400 (1960", @"Volkswagen Kübewagen (WWII German military Jeep-like vehicle) (Rear doors)", @"Wanderer W24 (1937–1940)", @"Zastava 750 (1956–1969)", @"ZAZ-96"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableController = [[BumpTableController alloc] initWithTableView:_tableView];
    [self updateView];

    //test to see if selection disappears
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self updateView];
    });
}

//returns whether it's actually selected
- (BOOL)toggleSelectionForKey:(NSObject<NSCopying> *)key {
    if ([self.selectedKeys containsObject:key]) {
        [self.selectedKeys removeObject:key];
        return NO;
    } else {
        [self.selectedKeys addObject:key];
        return YES;
    }
}

- (BOOL)isSelectedKey:(NSObject<NSCopying> *)key {
    return [self.selectedKeys containsObject:key];
}

- (void)setCell:(UITableViewCell *)cell selected:(BOOL)selected {
    if (selected) {
        cell.textLabel.textColor = [UIColor greenColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
}

- (void)updateView {
    __weak BTVViewController *weakSelf = self;
    BumpTableRow *row;
    NSMutableArray *rows = [NSMutableArray arrayWithCapacity:[_baseData count]];
    for (NSString *str in _baseData) {
        row = [BumpTableRow rowWithKey:str height:44 reuseIdentifier:@"Cell"];
        row.customizer = ^(UITableViewCell *cell) {
            [weakSelf setCell:cell selected:[weakSelf isSelectedKey:str]];
            cell.textLabel.text = str;
        };
        row.onTap  = ^(UITableViewCell *cell) {
            [weakSelf setCell:cell selected:[weakSelf toggleSelectionForKey:str]];
        };
        [rows addObject:row];
    }
    [self.tableController transitionToModel:[BumpTableModel modelWithRows:rows]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
