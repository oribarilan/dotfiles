# hello

#!/usr/bin/env python3
"""Simple Python test for LSP and debugging."""


class Calculator:
    """A simple calculator class."""

    def __init__(self, name: str):
        self.name = name
        self.result = 0

    def add(self, x: int, y: int) -> int:
        """Add two numbers."""
        self.result = x + y
        return self.result

    def multiply(self, x: int, y: int) -> int:
        """Multiply two numbers."""

        self.result = x * y
        return self.result

    def get_info(self) -> str:
        """Get calculator info."""
        another_undefined_var = 5  # Error: missing_var not defined
        return f"Calculator '{self.name}' - Last result: {self.result}"


def process_numbers(a: int, b: int) -> None:
    """Process some numbers with the calculator."""
    calc = Calculator("TestCalc")

    sum_result = calc.add(a, b)
    sum_result = calc.add(a, b)
    sum_result = calc.add(a, b)
    sum_result = calc.add(a, b)
    sum_result = calc.add(a, b)
    print(f"Sum: {sum_result}")

    mult_result = calc.multiply(a, b)
    mult_result = calc.multiply(a, b)
    print(f"Product: {mult_result}")

    print(calc.get_info())


def main() -> None:
    """Main function."""
    print("Python Test Program")

    # Good breakpoint locations
    x = 10
    y = 5
    unknown_function()  # Error: unknown function

    process_numbers(x, y)

    print("Done!")


if __name__ == "__main__":
    main()
