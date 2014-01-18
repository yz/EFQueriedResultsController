EFQueriedResultsController
==========================

Modeled after the NSFetchedResultsController, the EFQueriedResultsController works with the Parse.com platform to simplify managing the state of a list view (UITableView).

```objective-c
// Update your view controller to implement EFQueriedResultsControllerDelegate.h

// Add a property for a EFQueriedResultsController and implement its getter.

@property (nonatomic, strong) EFQueriedResultsController *queriedResultsController;

- (EFQueriedResultsController *)queriedResultsController
{
    if (!_queriedResultsController) {
                
        PFQuery *query = [PFQuery queryWithClassName:[EFShoppingListItem parseClassName]];
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        query.limit = 250;
        [query includeKey:@"category"];
        [query whereKeyExists:@"shoppingList"];
        
        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        
        _queriedResultsController = [[EFQueriedResultsController alloc] initWithQuery:query sectionNameKeyPath:@"category.name" sortDescriptors:sortDescriptors];
        _queriedResultsController.delegate = self;
    }
    
    return _queriedResultsController;
}

// Set the number of sections in your UITableView.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.queriedResultsController.sections.count;
}

// Set the number of rows in each section in your UITableView.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.queriedResultsController sectionInfoForSection:section].numberOfObjects;
}

// Notify your table that updates will begin.
- (void)controllerWillChangeContent:(EFQueriedResultsController *)controller
{
    [self.tableView beginUpdates];
}

// Notify your table when changes will end.
- (void)controllerDidChangeContent:(EFQueriedResultsController *)controller
{
    [self.tableView endUpdates];
}

// Implement the EFQueriedResultsControllerDelegate, updating your table rows based on the change type.
- (void)controller:(EFQueriedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(EFQueriedResultsChangeType)type
{
	switch(type) {
        case EFQueriedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case EFQueriedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case EFQueriedResultsChangeUpdate:
            
            // The activeIndexPath must be updated since the shoppingListItem may have moved to a different category.
            self.activeIndexPath = indexPath;
            
            [self configureCell:(EFShoppingListItemCell *)[self.tableView cellForRowAtIndexPath:indexPath] withObject:anObject];
            break;
    }
}

// Implement the EFQueriedResultsControllerDelegate, updating your table section based on the change type.
- (void)controller:(EFQueriedResultsController *)controller didChangeSection:(EFQueriedResultsSectionInfo *)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(EFQueriedResultsChangeType)type
{
    switch(type) {
        case EFQueriedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case EFQueriedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

// Get the cell, configuring it with the object from the EFQueriedResultsController.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    EFShoppingListItem *shoppingListItem = [self.queriedResultsController objectAtIndexPath:indexPath];    
    [self configureCell:cell shoppingListItem];    
    return cell;
}

// Example deleting an item from the EFQueriedResultsController when the item is tapped by the user.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EFShoppingListItem *shoppingListItem = [self.queriedResultsController objectAtIndexPath:indexPath];

    [self.queriedResultsController deleteObjects:@[shoppingListItem] onCompletion:^{        
        // TODO Do something useful.
    }];
}

// Example inserting an item into the EFQueriedResultsController.
- (void)shoppingListAddItemsViewController:(EFShoppingListAddItemsViewController *)viewController didChooseItems:(NSArray *)shoppingListItems
{
    [PFObject saveAllInBackground:shoppingListItems];
    [self.queriedResultsController insertObjects:shoppingListItems onCompletion:^{        
        // TODO Do something useful.
    }];
}
```

