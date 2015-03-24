//
//  ConflictViewController.m
//  Noty
//
//  Created by Guanqing Yan on 3/19/15.
//  Copyright (c) 2015 Guanqing Yan. All rights reserved.
//

#import "ConflictViewController.h"
#import "ViewController.h"
@interface ConflictViewController()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>
@property (strong,nonatomic) NSArray* versions;
@property NSInteger currentPage;
@end

@implementation ConflictViewController
-(void)setNote:(Note *)note{
    _note=note;
    self.versions = [@[[NSFileVersion currentVersionOfItemAtURL:note.fileURL]] arrayByAddingObjectsFromArray:[NSFileVersion unresolvedConflictVersionsOfItemAtURL:note.fileURL]];
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [self setDelegate:self];
    [self setDataSource:self];
    [self setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:true completion:nil];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveVersion:)];
    [self.navigationItem setRightBarButtonItem:item];
}
-(void)saveVersion:(id)sender{
    NSFileVersion* v = _versions[_currentPage];
    if (_currentPage!=0) {
        [v replaceItemAtURL:v.URL options:NSFileVersionReplacingByMoving error:nil];
    }
    [NSFileVersion removeOtherVersionsOfItemAtURL:v.URL error:nil];
    NSArray* conflictVersions = [NSFileVersion unresolvedConflictVersionsOfItemAtURL:_note.fileURL];
    for (NSFileVersion* fileVersion in conflictVersions) {
        fileVersion.resolved = YES;
    }
    [self.navigationController popViewControllerAnimated:true];
}
-(UIViewController*)viewControllerAtIndex:(NSInteger)index{
    if (index<0||index>=self.versions.count) {
        return nil;
    }
    NSFileVersion* v = self.versions[index];
    UIViewController* vc = [[UIViewController alloc] init];
    UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 500, 300)];
    [vc.view setBackgroundColor:[UIColor whiteColor]];
    [vc.view addSubview:l];
    [vc.view setTag:index];
    [l setLineBreakMode:NSLineBreakByCharWrapping];
    [l setNumberOfLines:0];
    [l setText:[NSString stringWithFormat:@"Name:%@\nModified by:%@\nTime:%@\n",v.localizedName,v.localizedNameOfSavingComputer,v.modificationDate]];
    return vc;
}
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        int currentIndex = (int)((UIViewController *)[self.viewControllers objectAtIndex:0]).view.tag;
        self.currentPage = currentIndex;
    }
}
-(UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    return [self viewControllerAtIndex:viewController.view.tag+1];
}
-(UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    return [self viewControllerAtIndex:viewController.view.tag-1];
}
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [self.versions count];
}

@end
