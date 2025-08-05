namespace TestCSharp
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("=== C# Test Program ===");
            Console.WriteLine("Testing Roslyn LSP functionality...\n");

            // Test basic variables and IntelliSense
            string message = "Hello from C#!";
            int number = 42;
            bool isWorking = true;
      
            Console.WriteLine($"Message: {message}"
                );
            Console.WriteLine($"Number: {number}");
            Console.WriteLine($"Status: {(isWorking ? "Working" : "Not Working")}\n");

            // Test collections and LINQ
            var numbers = new List<int> { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
            var evenNumbers = numbers.Where(n => n % 2 == 0).ToList();
            
            Console.WriteLine("Even numbers:");
            foreach (var num2 in evenNumbers)
            {
                Console.WriteLine($"  {num2}");
            }

            // Test methods
            int result = AddNumbers(10, 20);
            Console.WriteLine($"\nAddition result: {result}");

            // Test class instantiation
            var person = new Person("John Doe", 30);
            person.Greet();

            Console.WriteLine("\n=== Test Complete ===");
            Console.WriteLine("Press any key to exit...");
            Console.ReadKey();
        }

        // Test method definition and IntelliSense
        static int AddNumbers(int a, int b)
        {
            return a + b;
        }
    }

    // Test class definition
    public class Person
    {
        public string Name { get; set; }
        public int Age { get; set; }

        public Person(string name, int age)
        {
            Name = name;
            Age = age;
        }

        public void GrowOld()
        {
            Age++;
            Console.WriteLine($"{Name} is now {Age} years old.");
        }

        public void GetMarried()
        {
            Console.WriteLine($"{Name} is getting married!");
            GrowOld();
            GrowOld();
        }


        public void Greet()
        {
            Console.WriteLine($"Hello, my name is {Name} and I'm {Age} years old.");
        }
        // Test method with more complex logic
        public bool IsAdult()
        {
            return Age >= 18;
        }
    }
}
