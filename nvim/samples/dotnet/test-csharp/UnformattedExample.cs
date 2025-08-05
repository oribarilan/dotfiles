using System;using System.Collections.Generic;using System.Linq;
namespace TestCSharp{
public class UnformattedExample{
private string name;private int age;private List<string> items;
public UnformattedExample(string name,int age){
this.name=name;this.age=age;
items=new List<string>();}
public void AddItem(string item){if(string.IsNullOrEmpty(item)){
throw new ArgumentException("Item cannot be null or empty");}
items.Add(item);Console.WriteLine($"Added item: {item}");}
public string GetInfo(){
var itemCount=items.Count;
return $"Name: {name}, Age: {age}, Items: {itemCount}";}
public List<string> GetFilteredItems(Func<string,bool> filter){
return items.Where(filter).ToList();}
public void ProcessItems(){
for(int i=0;i<items.Count;i++){
var item=items[i];
if(item.Length>5){
Console.WriteLine($"Long item: {item}");}else{
Console.WriteLine($"Short item: {item}");}}}
public static void TestMethod(){
var example=new UnformattedExample("Test User",25);
example.AddItem("apple");example.AddItem("banana");
example.AddItem("cherry");example.AddItem("date");
Console.WriteLine(example.GetInfo());
var longItems=example.GetFilteredItems(item=>item.Length>5);
Console.WriteLine($"Long items: {string.Join(", ",longItems)}");}}}
