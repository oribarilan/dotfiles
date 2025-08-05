# C# Test Project for Roslyn LSP

This is a simple C# console application to test your Roslyn LSP setup in Neovim.

## Prerequisites

- .NET SDK 8.0 or later installed
- Neovim with the updated LSP configuration
- Roslyn language server installed via Mason

## Testing Your Setup

### 1. Build and Run the Application

```bash
cd test-csharp
dotnet run
```

Expected output:
```
=== C# Test Program ===
Testing Roslyn LSP functionality...

Message: Hello from C#!
Number: 42
Status: Working

Even numbers:
  2
  4
  6
  8
  10

Addition result: 30
Hello, my name is John Doe and I'm 30 years old.

=== Test Complete ===
Press any key to exit...
```

### 2. Test LSP Features in Neovim

Open `Program.cs` in Neovim and test these LSP features:

#### **IntelliSense/Completion**
- Type `Console.` and wait for autocompletion suggestions
- Type `numbers.` to see LINQ methods like `Where`, `Select`, etc.

#### **Go to Definition** (`grd`)
- Place cursor on `AddNumbers` call and press `grd`
- Should jump to the method definition

#### **Find References** (`grr`)
- Place cursor on `Person` class name and press `grr`
- Should show all usages of the Person class

#### **Hover Information**
- Hover over variables, methods, or types to see documentation

#### **Error Detection**
- Add a syntax error (e.g., missing semicolon)
- Should see red underlines and diagnostic messages

#### **Code Actions** (`gra`)
- Place cursor on a variable and press `gra`
- Should offer refactoring options

#### **Rename** (`grn`)
- Place cursor on a variable/method name and press `grn`
- Should rename all occurrences

### 3. Test Debugging (if configured)

```bash
# Build in debug mode
dotnet build --configuration Debug

# Run with debugger symbols
dotnet run --configuration Debug
```

## Troubleshooting

If LSP features aren't working:

1. **Check Roslyn installation:**
   ```vim
   :Mason
   ```
   Look for "roslyn" in the installed packages.

2. **Check LSP status:**
   ```vim
   :LspInfo
   ```
   Should show Roslyn LSP attached to .cs files.

3. **Restart LSP:**
   ```vim
   :LspRestart
   ```

4. **Check Mason logs:**
   ```vim
   :MasonLog
   ```

## What This Tests

- **Basic C# syntax highlighting**
- **IntelliSense and autocompletion**
- **Error detection and diagnostics**
- **Go to definition and references**
- **Code navigation**
- **Project file recognition (.csproj)**
- **LINQ and modern C# features**
- **Class and method definitions**

If all these features work correctly, your Roslyn LSP setup is working perfectly!