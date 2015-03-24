//
//  ListViewController.m
//  Noty
//
//  Created by Guanqing Yan on 3/17/15.
//  Copyright (c) 2015 Guanqing Yan. All rights reserved.
//

#import "ListViewController.h"
#import "GYActionCounter.h"
#import "ConflictViewController.h"
#define kLoadDataAction @"kLoadDataAction"
#define kDeleteAction @"kDeleteAction"

@implementation ListViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.notes = [[NSMutableArray alloc] init];
    self.title = @"Notes";
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithTitle:@"add" style:UIBarButtonItemStylePlain target:self action:@selector(addNote:)];
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithTitle:@"delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteNotes)];
    self.navigationItem.rightBarButtonItem = addItem;
    self.navigationItem.leftBarButtonItem = deleteItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNotes) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryDidFinishGathering:) name:NSMetadataQueryDidFinishGatheringNotification object:nil];
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(loadNotes) forControlEvents:UIControlEventValueChanged];
    [GYActionCounter initialize];
}
-(void)addNote:(id)sender{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_hhmmss"];
    NSString* fileName  = [NSString stringWithFormat:@"Note_%@",[formatter stringFromDate:[NSDate date]]];
    NSURL* ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSURL* local = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    NSURL* iCloudURL = [[ubiq URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:fileName];
    NSURL* localURL = [local URLByAppendingPathComponent:fileName];
    Note* doc = [[Note alloc] initWithFileURL:localURL];
    [doc saveToURL:[doc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        if (success) {
            [self.notes addObject:doc];
            [self.tableView reloadData];
            dispatch_queue_t q_default;
            q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(q_default, ^(void) {
                NSError *error = nil;
                BOOL success = [[[NSFileManager alloc] init] setUbiquitous:YES itemAtURL:localURL
                                                            destinationURL:iCloudURL error:&error];
                if (!success) {
                    NSLog(@"setting ubiquitous failed: %@",[error description]);
                }
                [doc closeWithCompletionHandler:^(BOOL success) {
                    if (!success) {
                        NSLog(@"closing file failed");
                    }
                }];
            });
        }
    }];
}
-(void)loadNotes{
    NSLog(@"load notes called");
    NSURL* ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    if (ubiq) {
        self.query = [[NSMetadataQuery alloc] init];
        [self.query setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
        NSPredicate* pred = [NSPredicate predicateWithFormat:@"%K like 'Note_*'",NSMetadataItemFSNameKey];
        [self.query setPredicate:pred];
        [self.query startQuery];
    }
    else{
        NSLog(@"NO icould access");
    }
}
-(void)deleteNotes{
    [self.query stopQuery];
    
    __weak typeof(self) weakself = self;
    [GYActionCounter setCount:[self.notes count] Handler:^{
        [weakself.notes removeAllObjects];
        [weakself.tableView reloadData];
    } ForTask:kDeleteAction];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        for (int i=self.notes.count-1; i>=0; i--) {
            NSError* e1 =nil;
            [fileCoordinator coordinateWritingItemAtURL:[self.notes[i] fileURL]
                                                options:NSFileCoordinatorWritingForDeleting
                                                  error:&e1
                                             byAccessor:^(NSURL* writingURL) {
                                                 [self.notes[i] closeWithCompletionHandler:^(BOOL success) {
                                                     NSFileManager* fileManager = [[NSFileManager alloc] init];
                                                     NSError* e2 =nil;
                                                     [fileManager removeItemAtURL:writingURL error:&e2];
                                                     if (e2) {
                                                         NSLog(@"e2 error:%@",[e2 localizedDescription]);
                                                     }
                                                     [GYActionCounter decreaseCountForTask:kDeleteAction];
                                                     NSLog(@"%d:delete--",success);
                                                 }];
                                             }];
            if (e1) {
                NSLog(@"e1 error:%@",[e1 localizedDescription]);
            }
        }
    });
}
-(void)queryDidFinishGathering:(NSNotification*)n{
    NSLog(@"did finish query");
    [self loadData:self.query];
}
-(void)queryDidUpdate:(NSNotification*)n{
    NSLog(@"did receive update");
    [self loadData:self.query];
}
//- (void)logAllCloudStorageKeysForMetadataItem:(NSMetadataItem *)item
//{
//    NSNumber *isUbiquitous = [item valueForAttribute:NSMetadataItemIsUbiquitousKey];
//    NSNumber *hasUnresolvedConflicts = [item valueForAttribute:NSMetadataUbiquitousItemHasUnresolvedConflictsKey];
//    NSNumber *isDownloaded = [item valueForAttribute: NSMetadataUbiquitousItemIsDownloadedKey];
//    NSNumber *isDownloading = [item valueForAttribute:NSMetadataUbiquitousItemIsDownloadingKey];
//    NSNumber *isUploaded = [item valueForAttribute:NSMetadataUbiquitousItemIsUploadedKey];
//    NSNumber *isUploading = [item valueForAttribute:NSMetadataUbiquitousItemIsUploadingKey];
//    NSNumber *percentDownloaded = [item valueForAttribute:NSMetadataUbiquitousItemPercentDownloadedKey];
//    NSNumber *percentUploaded = [item valueForAttribute:NSMetadataUbiquitousItemPercentUploadedKey];
//    NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
//    BOOL documentExists = [[NSFileManager defaultManager] fileExistsAtPath:[url path]];
//    
//    NSLog(@"isUbiquitous:%@ hasUnresolvedConflicts:%@ isDownloaded:%@ isDownloading:%@ isUploaded:%@ isUploading:%@ %%downloaded:%@ %%uploaded:%@ documentExists:%i - %@", isUbiquitous, hasUnresolvedConflicts, isDownloaded, isDownloading, isUploaded, isUploading, percentDownloaded, percentUploaded, documentExists, url);
//}

-(void)loadData:(NSMetadataQuery*)query{
    [self.notes removeAllObjects];
    __weak typeof(self) weakself = self;
    [GYActionCounter setCount:[query resultCount] Handler:^{
        [weakself.notes sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[[obj1 fileURL] lastPathComponent] compare:[[obj2 fileURL] lastPathComponent] options:NSLiteralSearch];
        }];
        [weakself.tableView reloadData];
        if ([weakself.refreshControl isRefreshing]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM d, h:mm a"];
            NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
            NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                        forKey:NSForegroundColorAttributeName];
            NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
            weakself.refreshControl.attributedTitle = attributedTitle;
            [weakself.refreshControl endRefreshing];
        }
    } ForTask:kLoadDataAction];
    
    [query enumerateResultsUsingBlock:^(id result, NSUInteger idx, BOOL *stop) {
        NSURL* url = [result valueForAttribute:NSMetadataItemURLKey];
        NSString* status =[result valueForAttribute:NSMetadataUbiquitousItemDownloadingStatusKey];
        NSLog(@"%@",status);
        if (status==NSMetadataUbiquitousItemDownloadingStatusNotDownloaded) {
            [[NSFileManager defaultManager] startDownloadingUbiquitousItemAtURL:url error:nil];
            return;
        }
        Note* doc = [[Note alloc] initWithFileURL:url];
        [doc openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self.notes addObject:doc];
                [GYActionCounter decreaseCountForTask:kLoadDataAction];
            }
            else{
                NSLog(@"failed to open from icloud");
            }
        }];
    }];
}
#pragma mark UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.notes.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    Note* note = _notes[indexPath.row];
    cell.textLabel.text = note.fileURL.lastPathComponent;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIDocumentState state = [_notes[indexPath.row] documentState];
    if (state & UIDocumentStateInConflict) {
        ConflictViewController* vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"conflictViewController"];
        [vc setNote:_notes[indexPath.row]];
        [self.navigationController pushViewController:vc animated:true];
    }
    else{
    ViewController* vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"noteViewController"];
    [vc setDoc:_notes[indexPath.row]];
    [self.navigationController pushViewController:vc animated:true];
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    UIDocumentState state = [_notes[indexPath.row] documentState];
//    if (state & UIDocumentStateEditingDisabled) {
//        [_textView resignFirstResponder];
//    }
    if (state & UIDocumentStateInConflict) {
        [[cell contentView] setBackgroundColor:[UIColor yellowColor]];
    }
    else{
        [[cell contentView] setBackgroundColor:[UIColor whiteColor]];
    }
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    Note* note = [self.notes objectAtIndex:sourceIndexPath.row];
    [self.notes removeObjectAtIndex:sourceIndexPath.row];
    [self.notes insertObject:note atIndex:destinationIndexPath.row];
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray* fileList = self.notes;
    NSURL* fileURL = [[fileList objectAtIndex:indexPath.row] fileURL];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        [fileCoordinator coordinateWritingItemAtURL:fileURL options:NSFileCoordinatorWritingForDeleting
                                              error:nil byAccessor:^(NSURL* writingURL) {
                                                  [[fileList objectAtIndex:indexPath.row] closeWithCompletionHandler:^(BOOL success) {
                                                      NSFileManager* fileManager = [[NSFileManager alloc] init];
                                                      [fileManager removeItemAtURL:writingURL error:nil];
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [fileList removeObjectAtIndex:indexPath.row];
                                                          [tableView deleteRowsAtIndexPaths:[[NSArray alloc] initWithObjects:&indexPath count:1]
                                                                           withRowAnimation:UITableViewRowAnimationLeft];
                                                      });
                                                  }];
                                              }];
    });
}
@end
