# story_creator

This project is meant to create stories to be used in a future application. This was developed to be launched with windows. I can not guarantee that it will work on all platforms.
No configuration should be required, just launch the project with the debugger.

## Features

### Nodes

You can create nodes, remove them and change their connections.

#### To create a new node: 

- Select an existing node by double clicking on it. It should turn purple and activate the form and other commands.
- Fill the content part, the node type and all other fields you would want.
- Press **"Create node"** to create a new node.
- A new node should be created, being the child of the existing node

#### To update a node

- Select an existing node.
- long press on it, it should fill the form with the values of the node you selected.
- change any field you want
- press **"Update node"** to update

#### Remove a node

- Select an existing node
- Press the red **"Remove"** button to delete

### Edges

All your nodes can be connected to each other with links.

#### To create a new edge (link)

- Select an existing edge
- Press on the **"link to"** button. The button should turn yellow.
- Press on the node you want to be the child of the first node you selected. This second node should turn yellow, and the button should display **"submit link"**.
- Press on this same button to validate

#### To delete an edge

- Select an existing node (the parent)
- press on **"Remove edge"**. It should turn yellow.
- select the child you want to delete the edge to. It should turn yellow
- Submit by pressing the same button.

        You can only remove direct child connections. Also, if the child has only one connection (that is the parent from which you want to remove the edge), it will be disconnected fron the tree. You will find the disconnected tree at the top, near the first node (there is a button "Go to first node" that will teleport you to it)


### Files

A file system allow you to create more stories. Just enter a file name and press **"load"**. It will create the file for you and create the initial node (might be hidden, press "go to first node" to find it).

A saving system allows you to go back to the last time you saved.