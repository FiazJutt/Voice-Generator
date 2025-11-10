import 'package:flutter/material.dart';

/// Voice metadata map: modelId -> {displayName, language, region, gender, properties}
  const Map<String, Map<String, dynamic>> deepgramVoices = {
    // ============ AURA 1 - English Voices ============
    'aura-asteria-en': {
      'displayName': 'Asteria',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'clear', 'confident', 'knowledgeable']
    },
    'aura-luna-en': {
      'displayName': 'Luna',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'friendly', 'natural', 'engaging']
    },
    'aura-stella-en': {
      'displayName': 'Stella',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'raspy', 'engaging', 'cheerful']
    },
    'aura-athena-en': {
      'displayName': 'Athena',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'smooth', 'calm', 'professional']
    },
    'aura-hera-en': {
      'displayName': 'Hera',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'deep', 'smooth', 'warm']
    },
    'aura-orion-en': {
      'displayName': 'Orion',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'approachable', 'comfortable', 'calm']
    },
    'aura-arcas-en': {
      'displayName': 'Arcas',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'natural', 'smooth', 'clear']
    },
    'aura-perseus-en': {
      'displayName': 'Perseus',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'expressive', 'melodic', 'charismatic']
    },
    'aura-angus-en': {
      'displayName': 'Angus',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'casual', 'friendly', 'patient']
    },
    'aura-orpheus-en': {
      'displayName': 'Orpheus',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'clear', 'trustworthy', 'professional']
    },
    'aura-helios-en': {
      'displayName': 'Helios',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'postive', 'comfortable', 'polite']
    },
    'aura-zeus-en': {
      'displayName': 'Zeus',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'deep', 'trustworthy', 'smooth']
    },

    // ============ AURA 2 - English Voices ============
    'aura-2-amalthea-en': {
      'displayName': 'Amalthea',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'engaging', 'natural', 'cheerful']
    },
    'aura-2-andromeda-en': {
      'displayName': 'Andromeda',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'casual', 'expressive', 'comfortable']
    },
    'aura-2-apollo-en': {
      'displayName': 'Apollo',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'confident', 'comfortable', 'casual']
    },
    'aura-2-arcas-en': {
      'displayName': 'Arcas 2',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'natural', 'smooth', 'clear', 'comfortable']
    },
    'aura-2-aries-en': {
      'displayName': 'Aries',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'warm', 'energetic', 'caring']
    },
    'aura-2-asteria-en': {
      'displayName': 'Asteria 2',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'clear', 'confident', 'knowledgeable', 'energetic']
    },
    'aura-2-athena-en': {
      'displayName': 'Athena 2',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'calm', 'smooth', 'professional']
    },
    'aura-2-atlas-en': {
      'displayName': 'Atlas',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'enthusiastic', 'confident', 'approachable', 'friendly']
    },
    'aura-2-aurora-en': {
      'displayName': 'Aurora',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'cheerful', 'expressive', 'energetic']
    },
    'aura-2-callista-en': {
      'displayName': 'Callista',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'clear', 'energetic', 'professional', 'smooth']
    },
    'aura-2-cordelia-en': {
      'displayName': 'Cordelia',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'approachable', 'warm', 'polite']
    },
    'aura-2-cora-en': {
      'displayName': 'Cora',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'smooth', 'melodic', 'caring']
    },
    'aura-2-delia-en': {
      'displayName': 'Delia',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'casual', 'friendly', 'cheerful', 'breathy']
    },
    'aura-2-draco-en': {
      'displayName': 'Draco',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'warm', 'approachable', 'trustworthy', 'baritone']
    },
    'aura-2-electra-en': {
      'displayName': 'Electra',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'professional', 'engaging', 'knowledgeable']
    },
    'aura-2-harmonia-en': {
      'displayName': 'Harmonia',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'empathetic', 'clear', 'calm', 'confident']
    },
    'aura-2-helena-en': {
      'displayName': 'Helena',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'caring', 'natural', 'positive', 'friendly', 'raspy']
    },
    'aura-2-hera-en': {
      'displayName': 'Hera 2',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'smooth', 'warm', 'professional']
    },
    'aura-2-hermes-en': {
      'displayName': 'Hermes',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'expressive', 'engaging', 'professional']
    },
    'aura-2-hyperion-en': {
      'displayName': 'Hyperion',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'caring', 'warm', 'empathetic']
    },
    'aura-2-iris-en': {
      'displayName': 'Iris',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'cheerful', 'positive', 'approachable']
    },
    'aura-2-janus-en': {
      'displayName': 'Janus',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['feminine', 'southern', 'smooth', 'trustworthy']
    },
    'aura-2-juno-en': {
      'displayName': 'Juno',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'natural', 'engaging', 'melodic', 'breathy']
    },
    'aura-2-jupiter-en': {
      'displayName': 'Jupiter',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'expressive', 'knowledgeable', 'baritone']
    },
    'aura-2-luna-en': {
      'displayName': 'Luna 2',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'friendly', 'natural', 'engaging']
    },
    'aura-2-mars-en': {
      'displayName': 'Mars',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'smooth', 'patient', 'trustworthy', 'baritone']
    },
    'aura-2-minerva-en': {
      'displayName': 'Minerva',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'positive', 'friendly', 'natural']
    },
    'aura-2-neptune-en': {
      'displayName': 'Neptune',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'professional', 'patient', 'polite']
    },
    'aura-2-odysseus-en': {
      'displayName': 'Odysseus',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'calm', 'smooth', 'comfortable', 'professional']
    },
    'aura-2-ophelia-en': {
      'displayName': 'Ophelia',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'expressive', 'enthusiastic', 'cheerful']
    },
    'aura-2-orion-en': {
      'displayName': 'Orion 2',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'approachable', 'comfortable', 'calm', 'polite']
    },
    'aura-2-orpheus-en': {
      'displayName': 'Orpheus 2',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'professional', 'clear', 'confident', 'trustworthy']
    },
    'aura-2-pandora-en': {
      'displayName': 'Pandora',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'smooth', 'calm', 'melodic', 'breathy']
    },
    'aura-2-phoebe-en': {
      'displayName': 'Phoebe',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'energetic', 'warm', 'casual']
    },
    'aura-2-pluto-en': {
      'displayName': 'Pluto',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'smooth', 'calm', 'empathetic', 'baritone']
    },
    'aura-2-saturn-en': {
      'displayName': 'Saturn',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'knowledgeable', 'confident', 'baritone']
    },
    'aura-2-selene-en': {
      'displayName': 'Selene',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'expressive', 'engaging', 'energetic']
    },
    'aura-2-thalia-en': {
      'displayName': 'Thalia',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'clear', 'confident', 'energetic', 'enthusiastic']
    },
    'aura-2-theia-en': {
      'displayName': 'Theia',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'expressive', 'polite', 'sincere']
    },
    'aura-2-vesta-en': {
      'displayName': 'Vesta',
      'language': 'English',
      'region': 'American',
      'gender': 'Female',
      'properties': ['feminine', 'natural', 'expressive', 'patient', 'empathetic']
    },
    'aura-2-zeus-en': {
      'displayName': 'Zeus 2',
      'language': 'English',
      'region': 'American',
      'gender': 'Male',
      'properties': ['masculine', 'deep', 'trustworthy', 'smooth']
    },

    // ============ AURA 2 - Spanish Voices ============
    'aura-2-sirio-es': {
      'displayName': 'Sirio',
      'language': 'Spanish',
      'region': 'Español',
      'gender': 'Male',
      'properties': ['masculine', 'breathy', 'confident', 'energetic', 'professional', 'raspy']
    },
    'aura-2-nestor-es': {
      'displayName': 'Néstor',
      'language': 'Spanish',
      'region': 'Español',
      'gender': 'Male',
      'properties': ['masculine', 'calm', 'professional', 'approachable', 'clear', 'confident']
    },
    'aura-2-carina-es': {
      'displayName': 'Carina',
      'language': 'Spanish',
      'region': 'Español',
      'gender': 'Female',
      'properties': ['feminine', 'professional', 'raspy', 'energetic', 'breathy', 'confident']
    },
    'aura-2-celeste-es': {
      'displayName': 'Celeste',
      'language': 'Spanish',
      'region': 'Español',
      'gender': 'Female',
      'properties': ['feminine', 'clear', 'energetic', 'positive', 'friendly', 'enthusiastic']
    },
    'aura-2-alvaro-es': {
      'displayName': 'Álvaro',
      'language': 'Spanish',
      'region': 'Español',
      'gender': 'Male',
      'properties': ['masculine', 'calm', 'professional', 'clear', 'knowledgeable', 'approachable']
    },
    'aura-2-diana-es': {
      'displayName': 'Diana',
      'language': 'Spanish',
      'region': 'Español',
      'gender': 'Female',
      'properties': ['feminine', 'professional', 'confident', 'expressive', 'polite', 'knowledgeable']
    },
    'aura-2-aquila-es': {
      'displayName': 'Áquila',
      'language': 'Spanish',
      'region': 'Español',
      'gender': 'Female',
      'properties': ['masculine', 'casual', 'comfortable', 'confident', 'expressive', 'enthusiastic']
    },
    'aura-2-selena-es': {
      'displayName': 'Selena',
      'language': 'Spanish',
      'region': 'Español',
      'gender': 'Female',
      'properties': ['feminine', 'approachable', 'calm', 'casual', 'friendly', 'positive']
    },
    'aura-2-estrella-es': {
      'displayName': 'Estrella',
      'language': 'Spanish',
      'region': 'Español',
      'gender': 'Female',
      'properties': ['feminine', 'approachable', 'calm', 'comfortable', 'expressive', 'natural']
    },
    'aura-2-javier-es': {
      'displayName': 'Javier',
      'language': 'Spanish',
      'region': 'Español',
      'gender': 'Male',
      'properties': ['masculine', 'approachable', 'calm', 'comfortable', 'friendly', 'professional']
    },
  };
