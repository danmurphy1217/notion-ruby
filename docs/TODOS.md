# Use Cases:
- sending daily system checks to notion
- check responses for emails, zendesk tickets, etc.
- test cases to cover all use cases [minimal functionality of something in production]

I think it might make sense to break the available methods up into Page-oriented methods (adding new blocks and performing page-structured actions) and then block-oriented methods that include styling the blocks and updating them or performing specific actions on them.

### right now, it is set up so that only a page block instance can access the create_page method, but I would rather it be so that any type of block can CREATE any type of other block, and then each separate block instance that inherits from the core template have additional neat methods (such as checked?= for the to-do block).
To make this happen, I need to re-structure things so that there is one core create method that any type of block can utilize, and that method takes in the type of block to create and them filters and incorporates the correct functionality from that point.

I need to find the intersection points between each POST method that creates the different blocks and then break things down from there. Cover as much surface area with the core create method as possible.

### I also feel like the get_block and get_block_Children_ids methods (and other methods from the Block class) should be interacted with through a "Page" block and not through individual blocks. But, I could also see value in getting the specific children for one block... Not sure, maybe just some re-naming for the classes/modules? The PAge class (Rather than block class) should inherit from the Client, and the Block (re-named from the Template) should inherit from the Page? That seems to make real intuitive sense.