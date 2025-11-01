import nigui

app.init()

var window = newWindow("NodePad")
window.width = 500
window.height = 400

var container = newLayoutContainer(Layout_Vertical)
window.add(container)

var textArea = newTextArea()
container.add(textArea)

# Set the layout properties *on the control*
textArea.widthMode = WidthMode_Fill
textArea.heightMode = HeightMode_Fill

var syncButton = newButton("Sync")
container.add(syncButton)

syncButton.onClick = proc(event: ClickEvent) =
  let text = textArea.text
  echo "Sync button clicked! Text: ", text

window.show()
app.run()
