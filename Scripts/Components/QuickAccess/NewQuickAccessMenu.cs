using Godot;
using Godot.Collections;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

[GlobalClass]
public partial class NewQuickAccessMenu : Control
{
    private Button listButton = null;
    private LineEdit searchbar = null;
    private VBoxContainer list = null;
    private Control root = null;

    private Node lister = null;
    
    public enum STATES
    {
        OPEN,
        CLOSED
    }

    public STATES Status = STATES.CLOSED;

    public override void _Ready()
    {
        base._Ready();

        // Get used child nodes
        listButton = GetNode<Button>("%ListButton");
        searchbar = GetNode<LineEdit>("%Searchbar");
        list = GetNode<VBoxContainer>("%List");
        root = GetNode<Control>("%Root");

        // Get Autoloads
        lister = GetNode<Node>("/root/Lister");
    }

    public override void _Notification(int what)
    {
        base._Notification(what);

        switch(what)
        {
            case (int)NotificationResized:
                SizeUpdate();
                break;
        }
    }

    private Task _latestTask = Task.CompletedTask;
    private CancellationTokenSource _cancellationTokenSource;

    /**
     * Reload the quick access menu with items from the submitted query[q]
     */
    public async void Reload(string q)
    {
        // Based on: https://stackoverflow.com/questions/63420269/how-to-cancel-an-existing-task-and-run-a-new-task-when-it-completes
        _cancellationTokenSource?.Cancel();
        //await ToSignal(GetTree(), SceneTree.SignalName.ProcessFrame);
        var children = list.GetChildren();

        using (var cts = new CancellationTokenSource())
        {
            _cancellationTokenSource = cts;
            var previousTask = _latestTask;
            var newTask = new Task(() => Search(q, children, cts.Token), cts.Token);
            _latestTask = newTask;

            // Prevent an exception from any task to crash the application
            // It is possible that the newTask.Start() will throw too
            try { await previousTask; } catch { }
            try { newTask.Start(); await newTask; } catch { }

            // Ensure that the CTS will not be canceled after is has been disposed
            if (_cancellationTokenSource == cts) _cancellationTokenSource = null;
        }
    }

    private void Search(string q, Array<Node> children, CancellationToken cancellationToken)
    {
        if (q == "")
        {
            // Clear menu if search request is empty
            foreach (Button b in children)
            {
                if (cancellationToken.IsCancellationRequested)
                    return;

                b.CallDeferred("free");
            }
        }
        else
        {
            // List of existing items that match
            HashSet<String> skip = [];

            // Remove non matching items
            foreach (Button b in children)
            {
                if (cancellationToken.IsCancellationRequested)
                    return;

                if (b.Text.Contains(q, StringComparison.CurrentCultureIgnoreCase))
                    skip.Add(b.Text.ToLower());
                else
                    b.CallDeferred("free");
            }

            // Add missing
            Array<Resource> results = (Array<Resource>)lister.Get("music");
            foreach (var m in results.Where(t => 
                ((string)t.Get("name")).Contains(q, StringComparison.CurrentCultureIgnoreCase) && !skip.Contains(((string)t.Get("name")).ToLower()))
            )
            {
                if (cancellationToken.IsCancellationRequested)
                    return;
                
                NewQuickAccessButton b = new((string)m.Get("name"), (string)m.Get("path"));
                b.SetDeferred("custom_minimum_size", new Vector2(0, 75));
                b.CallDeferred("ConnectToPlayer", this);
                list.CallDeferred("add_child", b);
            }
        }
    }

    public void HideList()
    {
        Status = STATES.CLOSED;
        Reload("");
        GetNode<VBoxContainer>("%Vcont").Hide();
    }

    public void ShowList()
    {
        Status = STATES.OPEN;
        Reload("");
        GetNode<VBoxContainer>("%Vcont").Show();
    }

    public void OnListButtonPressed()
    {
        if (!Visible) return;

        Tween tween = CreateTween();

        if (root.Position.X == 0)
        {
            searchbar.ReleaseFocus();
            searchbar.Text = "";
            
            foreach (Button b in list.GetChildren())
                b.QueueFree();

            tween.TweenProperty(root, "position", new Vector2(-root.Size.X, 0), 0.4);
            tween.TweenCallback(Callable.From(HideList));
            listButton.Text = ">";
        }
        else
        {
            searchbar.GrabFocus();
            tween.TweenProperty(root, "position", Vector2.Zero, 0.4);
            ShowList();
            listButton.Text = "<";
        }
    }
	
    public void SizeUpdate()
    {
        if (root is null) return;

        root.Size = new Vector2(Size.X * root.AnchorRight, Size.Y);

        if (Status == STATES.OPEN)
            root.Position = new Vector2(0, root.Position.Y);
        else
            root.Position = new Vector2(-root.Size.X, root.Position.Y);
    }
}
