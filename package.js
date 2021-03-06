/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable no-console */
const path = require('path');
const fs = require('fs-extra');
const hasha = require('hasha');

const packageJson = require('./package.json');

const zipFileName = 'template-macos.zip';
const DIST_PATH = path.join(__dirname, 'dist');
const TEMPLATE_ZIP_PATH = path.join(DIST_PATH, zipFileName);
const TEMPLATE_JSON_PATH = path.join(DIST_PATH, 'template-macos.json');

Promise.resolve()
  .then(async () => {
    console.log(`Generating ${TEMPLATE_JSON_PATH}...`);
    fs.ensureFileSync(TEMPLATE_JSON_PATH);
    const sha256 = await hasha.fromFile(TEMPLATE_ZIP_PATH, { algorithm: 'sha256' });
    const { version, minimumChromelessVersion } = packageJson;
    fs.writeJSONSync(TEMPLATE_JSON_PATH, {
      version,
      minimumChromelessVersion,
      sha256,
      zipFileName,
      downloadUrl: `https://github.com/webcatalog/webkit-wrapper/releases/download/v${version}/${zipFileName}`,
    });
  })
  .then(() => {
    console.log('successful');
  })
  .catch((err) => {
    console.log(err);
    process.exit(1);
  });
