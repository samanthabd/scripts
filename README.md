# scripts
Powershell and Batch scripts

## sass-new

I got tired of manually creating/importing new Sass partials, so I made this.

(Quick note: 'Modules' refers to the folders partials are organised into, which contain an index file, and are `@use`d in the main scss file.)

Relies on the following assumptions, which more often than not are true for my workflow:
- a 'scss' subdirectory exists, and only one
- scss subdirectory architecture is similar to the [7-1 pattern](https://sass-guidelin.es/#the-7-1-pattern)
- 'scss/components' should be default location of new partials
- 'scss/abstracts' module exists

Run via the batch from command line:
`sass-new.bat [partial name] [module name (opt)]`

Does the following:
- Create a new scss partial in the specified module called `_partial-name.scss`
  - If no module is specified, defaults to 'components'
- Update the _index file with a @forward statement for the new partial.
- If the module or index file doesn't exist, it will create them.
- The new partial will include an @use statement for variables, and create an empty rule block with a class selector based on the partial name.

------- Examples --------
```
    * = new 
    ~ = modified
  
  sass-new.bat button contact-page
    --> scss
        ├─ abstracts
        ├─ base
        ├─ components
      * └─ contact-page
      *      ├─ _index.scss 
      *      └─ _button.scss 

  sass-new.bat button 
    --> scss
          ├─ abstracts
          ├─ base
          └─ components
        ~      ├─ _index.scss
        *      └─ _button.scss
```
#>