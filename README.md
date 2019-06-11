### Translator

Simple service for translating lines in a document for a given placeholder

 **Tested on:**
- Evolution 2.0.0-alpha
- pug-php/php 3.2

### Usage
* Install plugin
* Prepare translation files in `/translates` folder
* Configure and enable plugin
* Insert into document translation placeholders

```html
<!-- somewhere in document -->
<h2>i`page.title`</h2>
<p>i`page.content`</p>
```
```php
// /translates/en_US.php
page.title=Very cool title
page.content=Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt 
	  ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco 
	  laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in 
	  voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat
	  cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
```