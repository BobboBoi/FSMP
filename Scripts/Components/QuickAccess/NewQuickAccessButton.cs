using Godot;
using System;

[GlobalClass]
public partial class NewQuickAccessButton : Button
{

    private AudioStreamPlayer _player;
    private string path = "";

    public NewQuickAccessButton(string name, string path)
    {
        TextOverrunBehavior = TextServer.OverrunBehavior.TrimChar;
        SizeFlagsHorizontal = SizeFlags.ExpandFill;
        MouseDefaultCursorShape = CursorShape.PointingHand;
        FocusMode = FocusModeEnum.All;

        this.path = path;
        Text = name != "" ? name : path;
    }

    public override void _Ready()
    {
        base._Ready();

        // Can't grab autoloads so this will have to do :(
        _player = GetNode<AudioStreamPlayer>("/root/Player");
    }

    public override void _GuiInput(InputEvent input)
    {
        if (input.IsActionPressed("RightClick"))
        {
            var rcm = GetTree().GetFirstNodeInGroup("RightClickMenu");
            if (rcm == null) return;
            rcm.Call("Open", this);
        }

        else if (input.IsActionPressed("EnqueueNext"))
            _player.Call("EnqueueNextFromPathArray", new string[] { path });
        else if (input.IsActionPressed("Enqueue"))
            _player.Call("EnqueueFromPathArray", new string[] { path });
    }

    public void ConnectToPlayer(NewQuickAccessMenu menu)
    {
        Connect(SignalName.Pressed, Callable.From(() => {
            GetNode<AudioStreamPlayer>("/root/Player").Call("PlaySingleFromPath", path);
        }));

        Connect(SignalName.Pressed, Callable.From(menu.OnListButtonPressed));
    }
        
}
