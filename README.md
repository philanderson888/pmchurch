# pmchurch

## contents

- [pmchurch](#pmchurch)
  - [contents](#contents)
  - [getting started](#getting-started)

## getting started

modify `launch.json` 

alter these two lines

```json
"host": "192.168.87.44",
"password": "rokudev",
```

to match your roku device

then hit F5 or `run => start debugging` to run the code, let it compile to a zip at `\out\roku-deploy.zip` and push the zip to your roku tv, and that will run the code for you.

happy coding!