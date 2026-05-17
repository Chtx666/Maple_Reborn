using System.Diagnostics;
using Godot;
using Godot.Collections;

public partial class MainProcess : Node
{
	public string linesString;
	private Dictionary nodes;
	private string nowNode;
	private TextureRect bg;
	private Sprite2D character;
	private Label text;
	private Dictionary currentNode;
	private string nextNode;
	
	public override void _Ready()
	{
		bg = GetNode<TextureRect>("TextureRect");
		character = GetNode<Sprite2D>("Character");
		text = GetNode<Label>("Dialog/Label");
		bg.GuiInput += OnBGGuiInput;
		
		var linesPath =  "res://test_script.json";
		var linesFile = FileAccess.Open(linesPath, FileAccess.ModeFlags.Read);
		linesString = linesFile.GetAsText();
		linesFile.Close();
		
		var json = new Json();
		Error err = json.Parse(linesString);
		if (err != Error.Ok)
		{
			GD.PrintErr("剧本JSON解析失败");
			return;
		}

		var linesData = json.Data.AsGodotDictionary();
		nodes = linesData["nodes"].AsGodotDictionary();
		nowNode = linesData["start_node"].AsString();
		WhatIDoWhenANode();
	}

	private void WhatIDoWhenANode()
	{
		if (!nodes.ContainsKey(nowNode))
		{
			GD.PrintErr("节点不存在: " + nowNode);
			return;
		}
		currentNode = nodes[nowNode].AsGodotDictionary();
		string bgName = currentNode.ContainsKey("bg") && currentNode["bg"].VariantType != Variant.Type.Nil ? currentNode["bg"].AsString() : null;
		string charName = currentNode.ContainsKey("character") && currentNode["character"].VariantType != Variant.Type.Nil ? currentNode["character"].AsString() : null;
		string textName = currentNode.ContainsKey("text") ? currentNode["text"].AsString() : null;
		if (bgName == null)
			bg.Texture = null;
		else
			bg.Texture = GD.Load<Texture2D>("res://Assets/" + bgName);
		if (charName == null)
			character.Texture = null;
		else
			character.Texture = GD.Load<Texture2D>("res://Assets/" + charName);
		if (textName == null)
			text.Text = null;
		else
			text.Text = textName;
		nextNode = currentNode.ContainsKey("next") ? currentNode["next"].AsString() : null;
	}
	
	private void OnBGGuiInput(InputEvent @event)
	{
		if (@event is InputEventMouseButton mouseButton && mouseButton.Pressed && mouseButton.ButtonIndex == MouseButton.Left)
		{
			nowNode = nextNode;
			WhatIDoWhenANode();
		}
	}
}
