echo 'Installing profile scripts...'

if [[ $OSTYPE == "darwin"* ]]; then
  echo 'Mac OS detected';
  if grep -q "`pwd`/profile_scripts/darwin.sh" ~/.profile; then
    echo 'Already installed'
  else
    echo "source `pwd`/profile_scripts/darwin.sh `pwd`" >> ~/.profile
    echo 'Installed'
  fi
else
  echo 'Currently only set up for MacOS';
fi
