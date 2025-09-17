using Godot;
using System;

public partial class Main : Node
{
	[Export]
	public PackedScene MobScene { get; set; }
	
	private void _on_mob_timer_timeout()
	{
		Mob mob = MobScene.Instantiate<Mob>();

		var mobSpawnLocation = GetNode<PathFollow3D>("SpawnPath/SpawnLocation");
		mobSpawnLocation.ProgressRatio = GD.Randf();

		Player player = GetNodeOrNull<Player>("Player");
		if (player == null)
		{
			GD.PrintErr("Player node not found, skipping mob spawn");
			return;
		}
		
		Vector3 playerPosition = player.Position;
		mob.Initialize(mobSpawnLocation.Position, playerPosition);
		AddChild(mob);

		mob.Squashed += GetNode<ScoreLabel>("UserInterface/ScoreLabel").OnMobSquashed;
	}
	public override void _Ready()
	{
		GetNode<Control>("UserInterface/Retry").Hide();

		var timer = GetNode<Timer>("MobTimer");
		timer.Start();
	}
	
	public override void _Input(InputEvent @event)
	{
		if (@event.IsActionPressed("ui_accept") && GetNodeOrNull<Control>("/root/Main/UserInterface/Retry").Visible)
		{
			GD.Print("ui_accept pressed in Main");
			GetTree().ReloadCurrentScene();
		}
	}
}
