BumpTableController
===================

A block based object-oriented api to deal with `UITableView`s.

Instead of manually querying your your `UITableView`'s model through index paths for every delegate and data source callback, simply hand a list of `BumpTableRow`s to a `BumpTableController`, and it manages the rest.

`BumpTableController` also makes dealing with asynchrounous changes to the underlying model easier. Simply create a new set of `BumpTableRow` objects and then call `transtionToModel:`. Aside from resetting the underlying model for your list, `transitionToModel:` also figures out insertion, deletion, and movement transtions for you. You get all these cell transitions for free.

Quick Start
-----------

1. Hand a UITableView to a BumpTableController to manage:

		self.tableController = [[BumpTableController alloc] initWithTableView:_tableView];

	BumpTableController is now the `delegate` and `dataSource` of the given UITableView.

2. Create an `NSArray` of BumpTableRow objects:

	    NSMutableArray *rows = [NSMutableArray arrayWithCapacity:[_myData count]];
	    for (NSString *str in _myData) {
	        BumpTableRow *row = [BumpTableRow rowWithKey:str height:44 reuseIdentifier:@"Cell"];
	        row.customizer = ^(UITableViewCell *cell) {
	            cell.textLabel.text = str;
	        };
	        [rows addObject:row];
	    }

 	The `key` of each BumpTableRow must be unique. This is how `transitionToModel:` below decides to to manage transisions.

3. Tell BumpTableController to use this list of rows:

	    [_tableController transitionToModel:[BumpTableModel modelWithRows:rows]];

	We recommend using `transitionToModel:` instead of `setModel:` since it manages cell insertion/movement/deletion transitions for you. `setModel` is simply `reloadData` under the covers for when you don't want transitions.

Tell Me More
------------

### Rows

The largest surface area of the API is in specifying individual BumpTableRow objects. You can almost think of Rows as individual controllers for each row in your list. Beyond what is shown above the row object let's you specify the following:

* `generator` callback to provide a custom `UITableViewCell` subclass to use.
* `onTap` callback for when a user taps on a row

### Sections

You can also specify sections and their headers using `BumpTableSection` objects:

	_allSection = [BumpTableSection sectionWithKey:@"allSection" rows:_fontRows];

You can see a detailed example of how to use this in the `Example/` subproject.

### Selection

`UITableView` has an odd take on selection. In an effort to provide lots of framework helpers for doing selection animations `UITableView` ends up owning what items in your list are selected or not. This however can lead to headaches especially when you are dealing with a `UIViewController` with two `UITableView`s with one the same backing model objects. This happens when you have a sperate search results UITableView on top of the regular UITableView.

For these reasons `BumpTableController` does not support dealing with `UITableView`s that have `allowsMultipleSelection` on. See the `Selection Example/` sub project to handle this case yourself.

### Searching

`BumpTableController` can deal with the searching for you as well. You must set the controller as your delegate like so:

	_search = [[UISearchDisplayController alloc] initWithSearchBar:_tableController.searchBar
	                                            contentsController:self];
	_search.searchResultsDataSource  = _tableController;
	_search.searchResultsDelegate = _tableController;
	_search.delegate = _tableController;

And specify the search string for each row:

	newRow.searchString = item;

To see more details on how to use this see the `Example/` sub project.

Status
------
We've used BumpTableController as an exculsively for UITableViews in the Flock app for iOS, and are in the process of replacing various parts of the Bump app. The basic APIs for specifying rows have been stable for a long time. Some of the lesser used features such as searching might see some further API cleanup in the furture. Feel free to submit pull requests to make it better.

Authors
-------
The first version was written by [Ian Macartney](http://ianmacartney.com) while he was at Bump. Since then the various members of the Bump iOS team have contributed to it's continual improvement (In no particular order):

* [Sahil Desai](https://github.com/Sahil)
* [Jason Ting](https://github.com/jzting)
* [Thomas Greany](https://github.com/tewks)
* [Indrajit Khare](https://github.com/ikhare)
* [Seth Raphael](https://github.com/magicseth)