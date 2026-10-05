Copyright (C) Pedro Andrade (2026) <br></br>
A logic circuitry simulator Built in Luau

⚠ This github page only contains images and the source code. Sounds and Instances can only be found on the RBXL file.

---
# Features:

- Flipflops, All logic gates and LEDs
- ✏ Editor tools (builder, remover, selection, wiring, cloning, rotation)
- You can also customize some editor settings like the rotational angle and the grid snap.

Showcase:
<img width="1387" height="799" alt="image" src="https://github.com/user-attachments/assets/129800c4-5f46-40ca-992c-aae524da1584" />

<br></br>

---
# Importing and Exporting:

- Serializer to save and load circuitry 💾 (/src/shared/Services/SerializationService/init.luau)

Here are the abstract types of objects this serializer works with. Circuitry contains circuits, and wiring between those circuits.

```luau
export type SerializedCircuitry = {
	Circuits: {
		[number]: SerializedCircuit,
	},
	Wires: { SerializedWire },
}

export type SerializedCircuit = {
	_type: string,
	_position: Vector3,
	_pins: {
		[number]: boolean, --> idx 3 means output .. (no logic gate with 3 inputs exist)
	}?,
	_rotational_angle: number,
	_uniqueId: string,
}

export type SerializedWire = {
	elementAindex: number,
	elementBindex: number,
	pinAindex: number, --> elementA[pins][pinAindex]
	pinBindex: number, --> elementB[pins][pinBindex] or 1
}
```

Take this full adder circuitry for example:
<img width="783" height="323" alt="image" src="https://github.com/user-attachments/assets/aa5bd6c8-c0b8-4ec5-bdc7-963c8572a6e0" />

When serialized, it looks like this:
[serialized.txt](https://github.com/user-attachments/files/33069217/serialized.txt)

💡 You can also encode a serialized piece of text into a Base64 string for easier transportation,
and then decode the Base64 string inside your forked serializer.

--- 
Forks are permitted and even *encouraged*. If you're willing to change the serializer, or add more features, feel free to do so;
